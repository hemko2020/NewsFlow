import '../entities/article.dart';
import '../entities/category.dart';
import '../repositories/article_repository.dart';

class GetArticles {
  final ArticleRepository repository;

  GetArticles(this.repository);

  Future<List<Article>> call({
    Category? category,
    int page = 1,
    String? query,
    String? country,
    String? language,
  }) => repository.getArticles(category: category, page: page, query: query, country: country, language: language);
}
