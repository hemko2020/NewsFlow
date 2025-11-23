import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';

import '../../core/constants/strings.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            title: const Text(
              AppStrings.favoritesTitle,
              style: TextStyle(color: Colors.white, fontFamily: 'Serif'),
            ),
            floating: true,
            pinned: false,
          ),
          favorites.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppStrings.noFavorites,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppStrings.addFavoritesPrompt,
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final article = favorites[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ArticleCard(
                        article: article,
                        onTap: () {
                          ref.read(selectedArticleProvider.notifier).state =
                              article;
                        },
                        onFavorite: () {
                          // Remove from favorites
                          ref
                              .read(favoritesNotifierProvider.notifier)
                              .toggleFavorite(article);
                        },
                        onShare: () {
                          Share.share('${article.title}\n\n${article.url}');
                        },
                        favoriteIcon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    );
                  }, childCount: favorites.length),
                ),
        ],
      ),
    );
  }
}
