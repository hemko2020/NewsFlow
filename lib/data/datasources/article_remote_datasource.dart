import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article_model.dart';
import '../../domain/entities/category.dart';

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
      apiKey = dotenv.get('NEWS_API_KEY');
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
    String url;
    if (newsApiCategory != null) {
      final sources = await getSourcesForCategory(newsApiCategory, country: country);
      final sourcesParam = sources.take(20).join(',');
      url = 'https://newsapi.org/v2/top-headlines?sources=$sourcesParam&apiKey=$apiKey&page=$page';
    } else {
      // Use everything with language if specified
      final languageParam = language != null ? '&language=$language' : '';
      url = 'https://newsapi.org/v2/everything?q=$searchQuery&sortBy=publishedAt&apiKey=$apiKey&page=$page$languageParam';
    }
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final articles = data['articles'] as List;
      return articles.map((json) {
        final model = ArticleModel.fromNewsApiJson(json);
        return model.copyWith(category: category);
      }).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  Future<List<String>> getSourcesForCategory(String newsApiCategory, {String? country}) async {
    if (apiKey.isEmpty) {
      return [];
    }
    final cacheKey = '${newsApiCategory}_${country ?? 'all'}';
    if (_sourcesCache.containsKey(cacheKey)) {
      return _sourcesCache[cacheKey]!;
    }
    final countryParam = country != null ? '&country=$country' : '';
    final url = 'https://newsapi.org/v2/sources?category=$newsApiCategory$countryParam&apiKey=$apiKey';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final sources = data['sources'] as List;
      final sourceIds = sources.map((source) => source['id'] as String).toList();
      _sourcesCache[cacheKey] = sourceIds;
      return sourceIds;
    } else {
      throw Exception('Failed to load sources');
    }
  }

  String _mapCategoryToQuery(Category category) {
    switch (category) {
      case Category.finance:
        return 'finance OR business OR economy';
      case Category.health:
        return 'health OR medical';
      case Category.technology:
        return 'technology OR tech OR AI OR software';
      case Category.sports:
        return 'sports OR football OR basketball OR tennis';
      case Category.entertainment:
        return 'entertainment OR movie OR music OR celebrity';
      case Category.sciences:
        return 'science OR research OR discovery';
    }
  }

  String? _mapCategoryToNewsApi(Category category) {
    switch (category) {
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
