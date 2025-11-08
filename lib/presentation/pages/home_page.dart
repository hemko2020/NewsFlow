import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/article_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncArticles = ref.watch(articleNotifierProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return asyncArticles.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('NewsFlow')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text('NewsFlow')),
        body: Center(child: Text('Error loading articles: $error')),
      ),
      data: (articles) => Scaffold(
        appBar: AppBar(title: Text('NewsFlow')),
        body: Column(
          children: [
            // Category chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        final category = selected
                            ? categories[index]
                            : Category.technology;
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      },
                    ),
                  );
                },
              ),
            ),
            // Articles list
            Expanded(
              child: articles.isEmpty
                  ? const Center(child: Text('No articles available'))
                  : ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: article.imageUrl != null
                                ? Image.network(
                                    article.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  )
                                : const Icon(Icons.article),
                            title: Text(article.title),
                            subtitle: Text(
                              '${article.source} • ${article.summary ?? article.description}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                                // TODO: toggle favorite
                              },
                            ),
                            onTap: () {
                              // TODO: open article
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
