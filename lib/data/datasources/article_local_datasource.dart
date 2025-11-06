import '../models/article_model.dart';

abstract class ArticleLocalDataSource {
  Future<List<ArticleModel>> getArticles({String? category, int limit = 50});
  Future<void> saveArticles(List<ArticleModel> articles);
  Future<List<ArticleModel>> getFavoriteArticles();
  Future<void> toggleFavorite(String articleId);
}

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  final List<ArticleModel> _articles = [];
  final Set<String> _favorites = {};

  @override
  Future<List<ArticleModel>> getArticles({
    String? category,
    int limit = 50,
  }) async {
    var articles = _articles;
    if (category != null) {
      articles = articles.where((a) => a.category.name == category).toList();
    }
    return articles.take(limit).toList();
  }

  @override
  Future<void> saveArticles(List<ArticleModel> articles) async {
    _articles.addAll(articles);
    // Remove duplicates if any
    _articles.toSet().toList();
  }

  @override
  Future<List<ArticleModel>> getFavoriteArticles() async {
    return _articles.where((a) => _favorites.contains(a.id)).toList();
  }

  @override
  Future<void> toggleFavorite(String articleId) async {
    if (_favorites.contains(articleId)) {
      _favorites.remove(articleId);
    } else {
      _favorites.add(articleId);
    }
  }
}
