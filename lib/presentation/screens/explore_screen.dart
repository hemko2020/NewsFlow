import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article.dart';
import '../providers/article_provider.dart';
import 'all_articles_screen.dart';

import '../../core/constants/strings.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articleNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.exploreTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Categories Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E), // Dark grey background
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.categoriesTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildCategoryChip(AppStrings.categoryEnvironment),
                          _buildCategoryChip(AppStrings.categoryEconomy),
                          _buildCategoryChip(AppStrings.categoryEducation),
                          _buildCategoryChip(AppStrings.categoryBusiness),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Latest News Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.latestNewsTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Serif',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllArticlesScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.viewAll,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Latest News List
                SizedBox(
                  height: 320,
                  child: articles.when(
                    data: (data) {
                      if (data.isEmpty) {
                        return const Center(
                          child: Text(
                            AppStrings.noArticlesFound,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final article = data[index];
                          return _buildNewsCard(context, ref, article);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(
                      child: Text(
                        '${AppStrings.errorPrefix}$e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, WidgetRef ref, Article article) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedArticleProvider.notifier).state = article;
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Eye Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 16),
            // Metadata
            Row(
              children: [
                Text(
                  _formatDuration(article.publishedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(color: Colors.grey[400])),
                ),
                Expanded(
                  child: Text(
                    article.source,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              article.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
