import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';

class ArticleModel extends Article {
  ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.url,
    required super.source,
    super.imageUrl,
    required super.publishedAt,
    required super.category,
    super.summary,
    super.sentiment,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(
        json['publishedAt'] ?? DateTime.now().toIso8601String(),
      ),
      category: Category.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => Category.politics,
      ),
      summary: json['summary'],
      sentiment: json['sentiment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'source': source,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category.name,
      'summary': summary,
      'sentiment': sentiment,
    };
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      url: article.url,
      source: article.source,
      imageUrl: article.imageUrl,
      publishedAt: article.publishedAt,
      category: article.category,
      summary: article.summary,
      sentiment: article.sentiment,
    );
  }

  // For NewsAPI response
  factory ArticleModel.fromNewsApiJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['url'] ?? '', // use url as id
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: DateTime.parse(
        json['publishedAt'] ?? DateTime.now().toIso8601String(),
      ),
      category: Category.politics, // default, will be set by category
    );
  }

  @override
  ArticleModel copyWith({
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
  }) {
    return ArticleModel(
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
    );
  }
}
