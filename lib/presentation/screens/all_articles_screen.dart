import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/strings.dart';
import '../../domain/entities/article.dart';
import '../providers/article_provider.dart';

class AllArticlesScreen extends ConsumerWidget {
  const AllArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsyncValue = ref.watch(articleNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          AppStrings.latestNewsTitle,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: articlesAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(
              child: Text(
                AppStrings.noArticlesFound,
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Adjust aspect ratio as needed
            ),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildGridArticleCard(context, ref, article);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text(
            '${AppStrings.errorPrefix}$e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildGridArticleCard(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedArticleProvider.notifier).state = article;
        Navigator.pop(context); // Go back to explore, main nav will show detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: article.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(article.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: article.imageUrl == null
                    ? const Center(child: Icon(Icons.image, color: Colors.grey))
                    : null,
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.source,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDuration(article.publishedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
