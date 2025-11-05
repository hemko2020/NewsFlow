import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_local_datasource.dart';
import '../datasources/article_remote_datasource.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;
  final ArticleLocalDataSource localDataSource;

  ArticleRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<Article>> getArticles({Category? category, int page = 1}) async {
    try {
      // Try remote first
      final remoteArticles = await remoteDataSource.getArticlesByCategory(category!, page: page);
      // Save to local
      await localDataSource.saveArticles(remoteArticles);
      return remoteArticles.map((model) => model as Article).toList();
    } catch (e) {
      // Fallback to local
      final localArticles = await localDataSource.getArticles(
        category: category?.name,
        limit: 50 * page,
      );
      return localArticles.map((model) => model as Article).toList();
    }
  }

  @override
  Future<Article> getArticleById(String id) async {
    // For now, search in local
    final articles = await localDataSource.getArticles();
    return articles.firstWhere((a) => a.id == id);
  }

  @override
  Future<void> saveArticles(List<Article> articles) async {
    final models = articles.map((a) => ArticleModel.fromEntity(a)).toList();
    await localDataSource.saveArticles(models);
  }

  @override
  Future<List<Article>> getFavoriteArticles() async {
    final models = await localDataSource.getFavoriteArticles();
    return models.map((model) => model as Article).toList();
  }

  @override
  Future<void> toggleFavorite(String articleId) async {
    await localDataSource.toggleFavorite(articleId);
  }
}
