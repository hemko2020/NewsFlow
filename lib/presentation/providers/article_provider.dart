import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
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

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((
  ref,
) {
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
  int currentPage = 1;
  bool isLoading = false;

  final Logger _logger = Logger('ArticleNotifier');

  ArticleNotifier(this.getArticles, {Category? initialCategory})
      : selectedCategory = initialCategory ?? Category.technology,
        super([]) {
    loadArticles();
  }

  Future<void> loadArticles({Category? category, bool loadMore = false}) async {
    if (isLoading) return;
    isLoading = true;

    final cat = category ?? selectedCategory;
    final page = loadMore ? currentPage + 1 : 1;

    try {
      final articles = await getArticles(category: cat, page: page);
      if (page == 1) {
        state = articles;
      } else {
        state = [...state, ...articles];
      }
      if (loadMore) currentPage = page;
    } catch (e) {
      // Handle error
      _logger.severe('Error loading articles: $e');
    } finally {
      isLoading = false;
    }
  }

  void selectCategory(Category category) {
    selectedCategory = category;
    currentPage = 1;
    loadArticles(category: category);
  }

  void loadMore() {
    loadArticles(loadMore: true);
  }
}

final selectedCategoryProvider = StateProvider<Category>(
  (ref) => Category.technology,
);

final articleNotifierProvider =
    StateNotifierProvider<ArticleNotifier, List<Article>>((ref) {
      final getArticles = ref.watch(getArticlesProvider);
      final selectedCategory = ref.watch(selectedCategoryProvider);
      return ArticleNotifier(getArticles, initialCategory: selectedCategory);
    });

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchNotifier extends StateNotifier<List<Article>> {
  final GetArticles getArticles;

  final Logger _logger = Logger('SearchNotifier');

  SearchNotifier(this.getArticles) : super([]);

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      // Use the getArticles with a special category that maps to search
      final articles = await getArticles(
        category: Category.technology,
        page: 1,
        query: query,
      );
      state = articles;
    } catch (e) {
      _logger.severe('Error searching articles: $e');
      state = [];
    }
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, List<Article>>((ref) {
      final getArticles = ref.watch(getArticlesProvider);
      return SearchNotifier(getArticles);
    });

class FavoritesNotifier extends StateNotifier<List<Article>> {
  final ArticleRepository repository;

  FavoritesNotifier(this.repository) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await repository.getFavoriteArticles();
    state = favorites;
  }

  Future<void> toggleFavorite(Article article) async {
    await repository.toggleFavorite(article.id);
    await loadFavorites(); // Reload favorites
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, List<Article>>((ref) {
      final repository = ref.watch(articleRepositoryProvider);
      return FavoritesNotifier(repository);
    });

final categoriesProvider = Provider<List<Category>>((ref) => Category.values);
