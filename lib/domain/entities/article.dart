import 'category.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final String url;
  final String source;
  final String? imageUrl;
  final DateTime publishedAt;
  final Category category;
  final String? summary; // AI generated
  final String? sentiment; // positive, negative, neutral
  final String? content;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    this.imageUrl,
    required this.publishedAt,
    required this.category,
    this.summary,
    this.sentiment,
    this.content,
  });

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? source,
    String? imageUrl,
    DateTime? publishedAt,
    Category? category,
    String? summary,
    String? sentiment,
    String? content,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      sentiment: sentiment ?? this.sentiment,
      content: content ?? this.content,
    );
  }
}
