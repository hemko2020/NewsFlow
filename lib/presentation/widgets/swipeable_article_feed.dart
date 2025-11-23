import 'package:flutter/material.dart';
import 'package:newsflow/core/constants/strings.dart';
import 'dart:ui' as ui;
import '../../domain/entities/article.dart';

class SwipeableArticleFeed extends StatefulWidget {
  final List<Article> articles;
  final Function(Article) onArticleTap;
  final Function() onLoadMore;

  const SwipeableArticleFeed({
    super.key,
    required this.articles,
    required this.onArticleTap,
    required this.onLoadMore,
  });

  @override
  State<SwipeableArticleFeed> createState() => _SwipeableArticleFeedState();
}

class _SwipeableArticleFeedState extends State<SwipeableArticleFeed> {
  late List<Article> _articles;

  @override
  void initState() {
    super.initState();
    _articles = List.from(widget.articles);
  }

  @override
  void didUpdateWidget(SwipeableArticleFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.articles != oldWidget.articles) {
      setState(() {
        _articles = List.from(widget.articles);
      });
    }
  }

  void _removeArticle(int index) {
    setState(() {
      _articles.removeAt(index);
    });

    if (_articles.length < 3) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_articles.isEmpty) {
      return const Center(
        child: Text('No more articles', style: TextStyle(color: Colors.white)),
      );
    }

    return SizedBox.expand(
      child: Stack(
        children: _articles
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final article = entry.value;

              // Only render the top 2 cards for performance
              if (index > 1) return const SizedBox.shrink();

              return Positioned.fill(
                child: index == 0
                    ? Dismissible(
                        key: Key(article.id),
                        direction: DismissDirection.up,
                        onDismissed: (direction) {
                          _removeArticle(0);
                        },
                        child: _buildArticleCard(article),
                      )
                    : Transform.scale(
                        scale: 0.95,
                        child: _buildArticleCard(article),
                      ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () => widget.onArticleTap(article),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Title and Eye Icon
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              fontFamily: 'Serif',
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD32F2F), // Red color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Image
                  if (article.imageUrl != null)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(article.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // Footer info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDate(article.publishedAt),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                article.source,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (article.description.isNotEmpty)
                          Text(
                            article.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays}${AppStrings.daysAgo}';
    }
  }
}
