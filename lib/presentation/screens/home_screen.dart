import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  WidgetRef? _ref;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToSelectedCategory(WidgetRef ref) {
    final selectedCategory = ref.read(selectedCategoryProvider);
    final categories = ref.read(categoriesProvider);
    final selectedIndex = categories.indexOf(selectedCategory);

    if (selectedIndex >= 0) {
      // Use WidgetsBinding to ensure the scroll controller is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _categoryScrollController.hasClients) {
          _performScrollToCategory(selectedIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Reached near the end (200 pixels tolerance), load more articles
      if (_ref != null) {
        _ref!.read(articleNotifierProvider.notifier).loadMore(
          selectedCountry: _ref!.read(selectedCountryProvider),
          selectedLanguage: _ref!.read(selectedLanguageProvider),
          deviceLanguage: _ref!.read(deviceLanguageProvider),
          geolocationAsync: _ref!.read(geolocationProvider),
        );
      }
    }
  }

  void _scrollToCategory(int index) {
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Check if the scroll controller is attached to a scroll view
      if (!_categoryScrollController.hasClients) {
        // If not attached yet, try again in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _categoryScrollController.hasClients) {
            _performScrollToCategory(index);
          }
        });
        return;
      }

      _performScrollToCategory(index);
    });
  }

  void _performScrollToCategory(int index) {
    // Calculate position to center the category (approximate)
    const categoryWidth = 120.0; // Approximate width of each category card
    const padding = 16.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * (categoryWidth + 8)) - (screenWidth / 2) + (categoryWidth / 2) + padding;

    final clampedOffset = targetOffset.clamp(0.0, _categoryScrollController.position.maxScrollExtent);

    _categoryScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        _ref = ref; // Store ref for use in _onScroll
        final asyncArticles = ref.watch(articleNotifierProvider);
        final categories = ref.watch(categoriesProvider);

        // Scroll to selected category when data is loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (asyncArticles.hasValue && categories.isNotEmpty) {
            _scrollToSelectedCategory(ref);
          }
        });

        return asyncArticles.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(child: Text('Error loading articles: $error')),
          ),
          data: (articles) {
            // Get top 5 articles for carousel
            final topStories = articles.take(5).toList();

            return Scaffold(
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar - make it more transparent so categories are visible
                  SliverAppBar(
                    title: const Text('NewsFlow'),
                    floating: true,
                    pinned: false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                    elevation: 0,
                  ),
                  // Top Stories Carousel
                  if (topStories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Top Stories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          autoPlayInterval: const Duration(seconds: 5),
                        ),
                        items: topStories.map((article) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  ref.read(selectedArticleProvider.notifier).state = article;
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: article.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(article.imageUrl!),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                              // Handle error silently
                                            },
                                          )
                                        : null,
                                    color: article.imageUrl == null
                                        ? Colors.grey[300]
                                        : null,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          article.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  // Category chips
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 60,
                      child: ListView.builder(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              ref.watch(selectedCategoryProvider) == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryCard(
                              category: category,
                              isSelected: isSelected,
                              onTap: () {
                                // Update selected category
                                ref.read(selectedCategoryProvider.notifier).state = category;

                                // Scroll to center the selected category
                                _scrollToCategory(index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Articles list
                  articles.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('No articles available')),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == articles.length) {
                                // Show loading indicator at the end
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final article = articles[index];
                              return ArticleCard(
                                article: article,
                                onTap: () {
                                  ref.read(selectedArticleProvider.notifier).state = article;
                                },
                                onFavorite: () {
                                  ref
                                      .read(favoritesNotifierProvider.notifier)
                                      .toggleFavorite(article);
                                },
                                onShare: () {
                                  Share.share('${article.title}\n\n${article.url}');
                                },
                              );
                            },
                            childCount:
                                articles.length + 1, // +1 for loading indicator
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
