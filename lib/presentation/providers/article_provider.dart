import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/article_local_datasource.dart';
import '../../data/datasources/article_remote_datasource.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/usecases/get_articles.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final articleLocalDataSourceProvider = Provider<ArticleLocalDataSource>((ref) {
  return ArticleLocalDataSourceImpl();
});

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return ArticleRemoteDataSourceImpl(client);
});

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  final localDataSource = ref.watch(articleLocalDataSourceProvider);
  return ArticleRepositoryImpl(remoteDataSource, localDataSource);
});

final getArticlesProvider = Provider<GetArticles>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return GetArticles(repository);
});

class ArticleNotifier extends StateNotifier<List<Article>> {
  final GetArticles getArticles;
  Category selectedCategory;

  ArticleNotifier(this.getArticles, {Category? initialCategory})
      : selectedCategory = initialCategory ?? Category.technology,
        super([]) {
    loadArticles();
  }

  Future<void> loadArticles({Category? category, int page = 1}) async {
    final cat = category ?? selectedCategory;
    final articles = await getArticles(category: cat, page: page);
    if (page == 1) {
      state = articles;
    } else {
      state = [...state, ...articles];
    }
  }

  void selectCategory(Category category) {
    selectedCategory = category;
    loadArticles(category: category);
  }
}

final selectedCategoryProvider = StateProvider<Category>((ref) => Category.technology);

final articleNotifierProvider = StateNotifierProvider<ArticleNotifier, List<Article>>((ref) {
  final getArticles = ref.watch(getArticlesProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return ArticleNotifier(getArticles, initialCategory: selectedCategory);
});

final categoriesProvider = Provider<List<Category>>((ref) => Category.values);
