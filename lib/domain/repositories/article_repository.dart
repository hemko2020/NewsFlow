import '../entities/article.dart';
import '../entities/category.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles({
    Category? category,
    int page = 1,
    String? query,
  });
  Future<Article> getArticleById(String id);
  Future<void> saveArticles(List<Article> articles);
  Future<List<Article>> getFavoriteArticles();
  Future<void> toggleFavorite(String articleId);
}
