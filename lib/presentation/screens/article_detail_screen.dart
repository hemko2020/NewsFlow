import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsflow/core/constants/strings.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/article.dart';
import '../providers/article_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  String _formatDuration(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesNotifierProvider)
        .any((fav) => fav.id == article.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row (Title + Close Button)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                              height: 1.2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            ref.read(selectedArticleProvider.notifier).state =
                                null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Image
                    if (article.imageUrl != null)
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: NetworkImage(article.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Metadata Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(article.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '|',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                          Text(
                            article.source,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Article Content
                    Text(
                      article.content != null && article.content!.isNotEmpty
                          ? article.content!
                          : (article.description.isNotEmpty
                                ? article.description
                                : AppStrings.noDescription),
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Summary (if available)
                    if (article.summary != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AI Summary',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.summary!,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Floating Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesNotifierProvider.notifier)
                              .toggleFavorite(article);
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Share.share('${article.title}\n\n${article.url}');
                        },
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
