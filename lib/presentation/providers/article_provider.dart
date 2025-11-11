import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:newsflow/data/datasources/article_local_datasource.dart';
import 'package:newsflow/data/datasources/article_remote_datasource.dart';
import 'package:newsflow/domain/repositories/article_repository.dart';
import 'package:newsflow/domain/usecases/get_articles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';

final dioProvider = Provider<Dio>((ref) => getIt<Dio>());

final articleLocalDataSourceProvider = Provider<ArticleLocalDataSource>((ref) => getIt<ArticleLocalDataSource>());

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) => getIt<ArticleRemoteDataSource>());

final articleRepositoryProvider = Provider<ArticleRepository>((ref) => getIt<ArticleRepository>());

final getArticlesProvider = Provider<GetArticles>((ref) => getIt<GetArticles>());

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

// Provider for geolocation (rétabli - fonctionnait bien avant)
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

class ArticleNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  final GetArticles getArticles;
  Category selectedCategory;
  int currentPage = 1;

  final Logger _logger = Logger('ArticleNotifier');

  ArticleNotifier(this.getArticles, {Category? initialCategory})
      : selectedCategory = initialCategory ?? Category.technology,
        super(AsyncValue.loading()) {
    // Don't call loadArticles in constructor - will be called by provider
  }

  Future<void> loadArticles({Category? category, bool loadMore = false, String? selectedCountry, String? selectedLanguage, String? deviceLanguage, AsyncValue<String?>? geolocationAsync}) async {
    final cat = category ?? selectedCategory;
    final page = loadMore ? currentPage + 1 : 1;
    final country = selectedCountry ?? geolocationAsync?.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final language = selectedLanguage ?? deviceLanguage;

    // Use country if available, else language
    final param = country != null ? {'country': country} : {'language': language};

    try {
      final articles = await getArticles(category: cat, page: page, country: param['country'], language: param['language']);
      if (mounted) {
        if (page == 1) {
          state = AsyncValue.data(articles);
        } else {
          state = AsyncValue.data([...state.value!, ...articles]);
        }
        if (loadMore) currentPage = page;
      }
    } catch (e) {
      _logger.severe('Error loading articles: $e');
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  void loadMore({String? selectedCountry, String? selectedLanguage, String? deviceLanguage, AsyncValue<String?>? geolocationAsync}) {
    loadArticles(loadMore: true, selectedCountry: selectedCountry, selectedLanguage: selectedLanguage, deviceLanguage: deviceLanguage, geolocationAsync: geolocationAsync);
  }

}

final selectedCategoryProvider = StateProvider<Category>(
  (ref) => Category.technology,
);

final articleNotifierProvider =
    StateNotifierProvider<ArticleNotifier, AsyncValue<List<Article>>>((ref) {
      final getArticles = ref.watch(getArticlesProvider);
      final selectedCategory = ref.watch(selectedCategoryProvider);
      final notifier = ArticleNotifier(getArticles, initialCategory: selectedCategory);
      final selectedCountry = ref.read(selectedCountryProvider);
      final selectedLanguage = ref.read(selectedLanguageProvider);
      final deviceLanguage = ref.read(deviceLanguageProvider);
      final geolocationAsync = ref.read(geolocationProvider);
      notifier.loadArticles(
        category: selectedCategory,
        selectedCountry: selectedCountry,
        selectedLanguage: selectedLanguage,
        deviceLanguage: deviceLanguage,
        geolocationAsync: geolocationAsync,
      );
      ref.listen(selectedCategoryProvider, (previous, next) {
        final selectedCountry = ref.read(selectedCountryProvider);
        final selectedLanguage = ref.read(selectedLanguageProvider);
        final deviceLanguage = ref.read(deviceLanguageProvider);
        final geolocationAsync = ref.read(geolocationProvider);
        notifier.loadArticles(
          category: next,
          selectedCountry: selectedCountry,
          selectedLanguage: selectedLanguage,
          deviceLanguage: deviceLanguage,
          geolocationAsync: geolocationAsync,
        );
      });
      return notifier;
    });

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchNotifier extends StateNotifier<List<Article>> {
  final GetArticles getArticles;

  final Logger _logger = Logger('SearchNotifier');

  SearchNotifier(this.getArticles) : super([]);

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      if (mounted) state = [];
      return;
    }

    try {
      // Use the getArticles with a special category that maps to search
      final articles = await getArticles(
        category: Category.technology,
        page: 1,
        query: query,
      );
      if (mounted) state = articles;
    } catch (e) {
      _logger.severe('Error searching articles: $e');
      if (mounted) state = [];
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
    if (mounted) state = favorites;
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
