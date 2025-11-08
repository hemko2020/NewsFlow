import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  late WidgetRef _ref;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the end, load more articles
      _ref.read(articleNotifierProvider.notifier).loadMore(
        selectedCountry: _ref.read(selectedCountryProvider),
        selectedLanguage: _ref.read(selectedLanguageProvider),
        deviceLanguage: _ref.read(deviceLanguageProvider),
        geolocationAsync: _ref.read(geolocationProvider),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        _ref = ref;
        final asyncArticles = ref.watch(articleNotifierProvider);
        final categories = ref.watch(categoriesProvider);

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
                  // App Bar
                  const SliverAppBar(
                    title: Text('NewsFlow'),
                    floating: true,
                    pinned: false,
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
                              return Container(
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
                                ref.read(selectedCategoryProvider.notifier).state =
                                    category;
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
                                  // TODO: Open article
                                },
                                onFavorite: () {
                                  ref
                                      .read(favoritesNotifierProvider.notifier)
                                      .toggleFavorite(article);
                                },
                                onShare: () {
                                  // TODO: share article
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
