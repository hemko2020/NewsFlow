import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newsflow/data/models/article_model.dart';
import 'package:newsflow/domain/entities/category.dart';

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
    try {
      // Essayer d'abord les variables d'environnement système (pour CI/production)
      apiKey = dotenv.get('NEWS_API_KEY', fallback: '');

      // Si pas trouvé dans .env, essayer les variables système
      if (apiKey.isEmpty) {
        apiKey = const String.fromEnvironment('NEWS_API_KEY', defaultValue: '');
      }

      if (apiKey.isEmpty) throw Exception('API key is empty');
    } catch (e) {
      // News API key not found, articles will not load
      apiKey = '';
    }
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
                return articles.map((json) {
                  final model = ArticleModel.fromNewsApiJson(json);
                  return model.copyWith(category: category);
                }).toList();
              }
            }
          } catch (e) {
            // Network error for sources API
          }
        }
      }

      // Fallback: Use everything with category query
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
        return '';
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
            return articles.map((json) {
              final model = ArticleModel.fromNewsApiJson(json);
              return model.copyWith(category: category);
            }).toList();
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
}
