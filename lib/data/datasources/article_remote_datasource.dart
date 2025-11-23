import 'package:dio/dio.dart';
import 'package:newsflow/data/models/article_model.dart';
import 'package:newsflow/domain/entities/category.dart';
import 'package:newsflow/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticlesByCategory(
    Category category, {
    int page = 1,
    String? query,
    String? country,
    String? language,
  });
  Future<List<String>> getSourcesForCategory(String newsApiCategory);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;
  late final String apiKey;
  final Map<String, List<String>> _sourcesCache = {};

  ArticleRemoteDataSourceImpl(this.dio) {
    apiKey = Env.newsApiKey;
  }

  @override
  Future<List<ArticleModel>> getArticlesByCategory(
    Category category, {
    int page = 1,
    String? query,
    String? country,
    String? language,
  }) async {
    if (apiKey.isEmpty) {
      return [];
    }
    final searchQuery = query ?? _mapCategoryToQuery(category);
    final newsApiCategory = _mapCategoryToNewsApi(category);

    try {
      // First try to get articles using NewsAPI sources
      if (newsApiCategory != null) {
        final sources = await getSourcesForCategory(
          newsApiCategory,
          country: country,
        );

        if (sources.isNotEmpty) {
          final sourcesParam = sources.take(20).join(',');
          String url =
              'https://newsapi.org/v2/top-headlines?sources=$sourcesParam&apiKey=$apiKey&page=$page';

          // Add language filter if specified
          if (language != null) {
            url += '&language=$language';
          }

          try {
            final response = await dio.get(url);

            if (response.statusCode == 200) {
              final data = response.data;
              final articles = data['articles'] as List;
              if (articles.isNotEmpty) {
                // Fetch full content in parallel
                final articleFutures = articles.map((json) async {
                  final model = ArticleModel.fromNewsApiJson(json);
                  String? fullContent = model.content;

                  // If content is missing or truncated (NewsAPI usually truncates), try to scrape
                  if (fullContent == null ||
                      fullContent.contains('[+') ||
                      fullContent.length < 200) {
                    final scrapedContent = await _fetchFullContent(model.url);
                    if (scrapedContent != null) {
                      fullContent = scrapedContent;
                    }
                  }

                  return model.copyWith(
                    category: category,
                    content: fullContent,
                  );
                });

                return await Future.wait(articleFutures);
              }
            }
          } catch (e) {
            // Network error for sources API
          }
        }
      }

      // Fallback 1: Try top-headlines with category and country (no sources)
      if (newsApiCategory != null) {
        String url =
            'https://newsapi.org/v2/top-headlines?category=$newsApiCategory&apiKey=$apiKey&page=$page';

        if (country != null) {
          url += '&country=$country';
        } else if (language != null) {
          // Note: top-headlines with category supports country OR language (undocumented but often works)
          // or just defaults to US/English if neither.
          // Safest is to use language if country is missing.
          url += '&language=$language';
        }

        try {
          final response = await dio.get(url);
          if (response.statusCode == 200) {
            final data = response.data;
            final articles = data['articles'] as List;
            if (articles.isNotEmpty) {
              // Fetch full content in parallel
              final articleFutures = articles.map((json) async {
                final model = ArticleModel.fromNewsApiJson(json);
                String? fullContent = model.content;

                if (fullContent == null ||
                    fullContent.contains('[+') ||
                    fullContent.length < 200) {
                  final scrapedContent = await _fetchFullContent(model.url);
                  if (scrapedContent != null) {
                    fullContent = scrapedContent;
                  }
                }

                return model.copyWith(category: category, content: fullContent);
              });

              return await Future.wait(articleFutures);
            }
          }
        } catch (e) {
          // Error in top-headlines fallback
        }
      }

      // Fallback 2: Use everything with category query
      return _fetchArticlesFromEverythingApi(
        searchQuery,
        page,
        language,
        category,
      );
    } catch (e) {
      // If all fails, try general search without category
      return _fetchArticlesFromEverythingApi(
        searchQuery,
        page,
        language,
        category,
      );
    }
  }

  @override
  Future<List<String>> getSourcesForCategory(
    String newsApiCategory, {
    String? country,
  }) async {
    if (apiKey.isEmpty) {
      return [];
    }
    final cacheKey = '${newsApiCategory}_${country ?? 'all'}';
    if (_sourcesCache.containsKey(cacheKey)) {
      return _sourcesCache[cacheKey]!;
    }
    final countryParam = country != null ? '&country=$country' : '';
    final url =
        'https://newsapi.org/v2/sources?category=$newsApiCategory$countryParam&apiKey=$apiKey';
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final sources = (data['sources'] as List)
            .map((source) => source['id'] as String)
            .toList();
        _sourcesCache[cacheKey] = sources;
        return sources;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  String _mapCategoryToQuery(Category category) {
    switch (category) {
      case Category.general:
        return 'news'; // Changed from empty string to 'news'
      case Category.finance:
        return 'finance';
      case Category.health:
        return 'health';
      case Category.technology:
        return 'technology';
      case Category.sports:
        return 'sports';
      case Category.entertainment:
        return 'entertainment';
      case Category.sciences:
        return 'science';
    }
  }

  Future<List<ArticleModel>> _fetchArticlesFromEverythingApi(
    String query,
    int page,
    String? language,
    Category category,
  ) async {
    final languageParam = language != null ? '&language=$language' : '';
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url =
        'https://newsapi.org/v2/everything?q=$encodedQuery&sortBy=publishedAt&apiKey=$apiKey&page=$page$languageParam';

    try {
      final response = await dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data.containsKey('articles')) {
          final articles = data['articles'] as List;
          if (articles.isNotEmpty) {
            // Fetch full content in parallel
            final articleFutures = articles.map((json) async {
              final model = ArticleModel.fromNewsApiJson(json);
              String? fullContent = model.content;

              // If content is missing or truncated, try to scrape
              if (fullContent == null ||
                  fullContent.contains('[+') ||
                  fullContent.length < 200) {
                final scrapedContent = await _fetchFullContent(model.url);
                if (scrapedContent != null) {
                  fullContent = scrapedContent;
                }
              }

              return model.copyWith(category: category, content: fullContent);
            });

            return await Future.wait(articleFutures);
          }
        }
      }
    } catch (e) {
      // Ignore network errors and return empty list
    }

    return [];
  }

  String? _mapCategoryToNewsApi(Category category) {
    switch (category) {
      case Category.general:
        return 'general';
      case Category.finance:
        return 'business';
      case Category.health:
        return 'health';
      case Category.technology:
        return 'technology';
      case Category.sports:
        return 'sports';
      case Category.entertainment:
        return 'entertainment';
      case Category.sciences:
        return 'science';
    }
  }

  Future<String?> _fetchFullContent(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final paragraphs = document.querySelectorAll('p');

        final buffer = StringBuffer();
        for (var p in paragraphs) {
          final text = p.text.trim();
          if (text.length > 50) {
            // Filter out short snippets like "Read more", "Advertisement"
            buffer.writeln(text);
            buffer.writeln(); // Add spacing
          }
        }

        final result = buffer.toString();
        return result.isNotEmpty ? result : null;
      }
    } catch (e) {
      // Ignore scraping errors
      return null;
    }
    return null;
  }
}
