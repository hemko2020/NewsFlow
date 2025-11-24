import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_provider.dart';
import '../widgets/swipeable_article_feed.dart';

import '../../core/constants/strings.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(articleNotifierProvider.notifier)
          .loadArticles(
            selectedCountry: ref.read(selectedCountryProvider),
            selectedLanguage: ref.read(selectedLanguageProvider),
            deviceLanguage: ref.read(deviceLanguageProvider),
            geolocationAsync: ref.read(geolocationProvider),
          );
    });
  }

  void _loadMore() {
    ref
        .read(articleNotifierProvider.notifier)
        .loadMore(
          selectedCountry: ref.read(selectedCountryProvider),
          selectedLanguage: ref.read(selectedLanguageProvider),
          deviceLanguage: ref.read(deviceLanguageProvider),
          geolocationAsync: ref.read(geolocationProvider),
        );
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, d MMMM').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsyncValue = ref.watch(articleNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Top Row: Logo + Notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Color(0xFFD32F2F), // Red color
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily:
                              'Serif', // Using a serif font for the logo
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Greeting + Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.goodMorning,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Feed Section
            Expanded(
              child: articlesAsyncValue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    '${AppStrings.errorPrefix}$error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                data: (articles) => SwipeableArticleFeed(
                  articles: articles,
                  onArticleTap: (article) {
                    ref.read(selectedArticleProvider.notifier).state = article;
                  },
                  onLoadMore: _loadMore,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
