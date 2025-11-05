import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Favoris'),
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
                          'Aucun favori',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ajoutez des articles à vos favoris',
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
                    return ArticleCard(
                      article: article,
                      onTap: () {
                        // TODO: Open article
                      },
                      onFavorite: () {
                        // Remove from favorites
                        ref
                            .read(favoritesNotifierProvider.notifier)
                            .toggleFavorite(article);
                      },
                      onShare: () {
                        // TODO: share article
                      },
                      favoriteIcon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    );
                  }, childCount: favorites.length),
                ),
        ],
      ),
    );
  }
}
