import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article_model.dart';
import '../../domain/entities/category.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticlesByCategory(Category category, {int page = 1});
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final http.Client client;
  final String apiKey = '6e109140efd34a0d805afe229f95f4b4'; // TODO: secure this

  ArticleRemoteDataSourceImpl(this.client);

  @override
  Future<List<ArticleModel>> getArticlesByCategory(Category category, {int page = 1}) async {
    final queryParam = _mapCategoryToQuery(category);
    final url = 'https://newsapi.org/v2/everything?q=$queryParam&from=2025-10-05&sortBy=publishedAt&apiKey=$apiKey&page=$page';
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final articles = data['articles'] as List;
      return articles.map((json) {
        final model = ArticleModel.fromNewsApiJson(json);
        return model.copyWith(category: category);
      }).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  String _mapCategoryToQuery(Category category) {
    switch (category) {
      case Category.politics:
        return 'politics';
      case Category.finance:
        return 'finance OR business OR economy';
      case Category.health:
        return 'health OR medical';
      case Category.technology:
        return 'technology OR tech OR AI OR software';
      case Category.sciences:
        return 'science OR research OR discovery';
      case Category.sports:
        return 'sports OR football OR basketball OR tennis';
      case Category.entertainment:
        return 'entertainment OR movie OR music OR celebrity';
      default:
        return 'news';
    }
  }
}
