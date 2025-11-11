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
    // Error in geolocation
  }
  return null;
});

// Provider for selected country
final selectedCountryProvider = StateNotifierProvider<CountryNotifier, String?>((ref) {
  return CountryNotifier(ref);
});

class CountryNotifier extends StateNotifier<String?> {
  final Ref ref;

  CountryNotifier(this.ref) : super(null) {
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCountry = prefs.getString('selectedCountry');

    if (savedCountry != null) {
      state = savedCountry;
    } else {
      // If no saved country, check geolocation
      try {
        final geolocationAsync = await ref.read(geolocationProvider.future);
        if (geolocationAsync == 'fr') {
          // User is in France, set "fr" as default country
          state = 'fr';
          await prefs.setString('selectedCountry', 'fr');
        }
        // Otherwise leave null to use language
      } catch (e) {
        // If geolocation error, use default language
      }
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
  return LanguageNotifier(ref);
});

class LanguageNotifier extends StateNotifier<String?> {
  final Ref ref;

  LanguageNotifier(this.ref) : super(null) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');

    if (savedLanguage != null) {
      state = savedLanguage;
    } else {
      // If no saved language, check if user is in France
      try {
        final geolocationAsync = await ref.read(geolocationProvider.future);
        if (geolocationAsync == 'fr') {
          // User is in France, set "fr" as default language
          state = 'fr';
          await prefs.setString('selectedLanguage', 'fr');
        } else {
          // Otherwise use device language
          final deviceLanguage = ref.read(deviceLanguageProvider);
          state = deviceLanguage;
          await prefs.setString('selectedLanguage', deviceLanguage);
        }
      } catch (e) {
        // If geolocation error, use device language
        final deviceLanguage = ref.read(deviceLanguageProvider);
        state = deviceLanguage;
        await prefs.setString('selectedLanguage', deviceLanguage);
      }
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
  bool _isLoading = false; // Add loading flag to prevent concurrent requests

  final Logger _logger = Logger('ArticleNotifier');

  ArticleNotifier(this.getArticles)
      : selectedCategory = Category.general, // Default category
        super(AsyncValue.loading()) {
    // Don't call loadArticles in constructor - will be called by provider
  }

  Future<void> loadArticles({Category? category, bool loadMore = false, String? selectedCountry, String? selectedLanguage, String? deviceLanguage, AsyncValue<String?>? geolocationAsync}) async {
    // Prevent concurrent requests
    if (_isLoading && !loadMore) {
      return;
    }

    _isLoading = true;
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
    } finally {
      _isLoading = false;
    }
  }

  void loadMore({String? selectedCountry, String? selectedLanguage, String? deviceLanguage, AsyncValue<String?>? geolocationAsync}) {
    loadArticles(loadMore: true, selectedCountry: selectedCountry, selectedLanguage: selectedLanguage, deviceLanguage: deviceLanguage, geolocationAsync: geolocationAsync);
  }

}

final selectedCategoryProvider = StateProvider<Category>(
  (ref) => Category.general,
);

final articleNotifierProvider =
    StateNotifierProvider<ArticleNotifier, AsyncValue<List<Article>>>((ref) {
      final getArticles = ref.watch(getArticlesProvider);
      final notifier = ArticleNotifier(getArticles);

      // Watch for category changes and load articles
      ref.listen(selectedCategoryProvider, (previous, next) {
        try {
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
        } catch (e) {
          // Log the error but don't crash the app
          Logger('articleNotifierProvider').severe('Error loading articles on category change: $e');
        }
      });

      // Initial load with default category
      final selectedCountry = ref.read(selectedCountryProvider);
      final selectedLanguage = ref.read(selectedLanguageProvider);
      final deviceLanguage = ref.read(deviceLanguageProvider);
      final geolocationAsync = ref.read(geolocationProvider);
      notifier.loadArticles(
        category: Category.general, // Default category
        selectedCountry: selectedCountry,
        selectedLanguage: selectedLanguage,
        deviceLanguage: deviceLanguage,
        geolocationAsync: geolocationAsync,
      );

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

// Provider for selected article (for detail view)
final selectedArticleProvider = StateProvider<Article?>((ref) => null);

final categoriesProvider = Provider<List<Category>>((ref) => Category.values);
