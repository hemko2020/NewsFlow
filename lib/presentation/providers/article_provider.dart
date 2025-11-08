import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/article_local_datasource.dart';
import '../../data/datasources/article_remote_datasource.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/usecases/get_articles.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final articleLocalDataSourceProvider = Provider<ArticleLocalDataSource>((ref) {
  return ArticleLocalDataSourceImpl();
});

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio);
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

// Provider for device language
final deviceLanguageProvider = Provider<String>((ref) {
  // Get the first locale from the device
  final locales = PlatformDispatcher.instance.locales;
  if (locales.isNotEmpty) {
    final languageCode = locales.first.languageCode;
    // Map to supported NewsAPI languages
    const supportedLanguages = [
      'ar', 'en', 'de', 'es', 'fr', 'it', 'he', 'nl', 'no', 'pt', 'ru', 'sv', 'ud', 'zh'
    ];
    return supportedLanguages.contains(languageCode) ? languageCode : 'en';
  }
  return 'en';
});

// Provider for geolocation
final geolocationProvider = FutureProvider<String?>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final countryCode = placemarks.first.isoCountryCode?.toLowerCase();
      return countryCode;
    }
  } catch (e) {
    // Handle error
  }
  return null;
});

// Provider for selected country
final selectedCountryProvider = StateNotifierProvider<CountryNotifier, String?>((ref) {
  return CountryNotifier();
});

class CountryNotifier extends StateNotifier<String?> {
  CountryNotifier() : super(null) {
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selectedCountry');
    if (country != null) {
      state = country;
    }
  }

  Future<void> setCountry(String? country) async {
    state = country;
    final prefs = await SharedPreferences.getInstance();
    if (country != null) {
      await prefs.setString('selectedCountry', country);
    } else {
      await prefs.remove('selectedCountry');
    }
  }
}

// Provider for selected language
final selectedLanguageProvider = StateNotifierProvider<LanguageNotifier, String?>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String?> {
  LanguageNotifier() : super(null) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selectedLanguage');
    if (language != null) {
      state = language;
    }
  }

  Future<void> setLanguage(String? language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    if (language != null) {
      await prefs.setString('selectedLanguage', language);
    } else {
      await prefs.remove('selectedLanguage');
    }
  }
}

class ArticleNotifier extends StateNotifier<List<Article>> {
  final GetArticles getArticles;
  final Ref ref;
  Category selectedCategory;
  int currentPage = 1;
  bool isLoading = false;

  final Logger _logger = Logger('ArticleNotifier');

  ArticleNotifier(this.getArticles, this.ref, {Category? initialCategory})
      : selectedCategory = initialCategory ?? Category.technology,
        super([]) {
    loadArticles();
  }

  Future<void> loadArticles({Category? category, bool loadMore = false}) async {
    if (isLoading) return;
    isLoading = true;

    final cat = category ?? selectedCategory;
    final page = loadMore ? currentPage + 1 : 1;
    final selectedCountry = ref.read(selectedCountryProvider);
    final selectedLanguage = ref.read(selectedLanguageProvider);
    final deviceLanguage = ref.read(deviceLanguageProvider);
    final geolocationAsync = ref.read(geolocationProvider);
    final country = selectedCountry ?? geolocationAsync.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final language = selectedLanguage ?? deviceLanguage;

    // Use country if available, else language
    final param = country != null ? {'country': country} : {'language': language};

    try {
      final articles = await getArticles(category: cat, page: page, country: param['country'], language: param['language']);
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
      return ArticleNotifier(getArticles, ref, initialCategory: selectedCategory);
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
