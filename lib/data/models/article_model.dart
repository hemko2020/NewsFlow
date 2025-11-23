// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/category.dart';

part 'article_model.g.dart';

@JsonSerializable()
class ArticleModel extends Article {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String url;
  @override
  final String source;
  @override
  final String? imageUrl;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  @override
  final DateTime publishedAt;

  @JsonKey(unknownEnumValue: Category.technology)
  @override
  final Category category;

  @override
  final String? summary; // AI generated
  @override
  final String? sentiment; // positive, negative, neutral
  @override
  final String? content;

  ArticleModel({
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
  }) : super(
         id: id,
         title: title,
         description: description,
         url: url,
         source: source,
         imageUrl: imageUrl,
         publishedAt: publishedAt,
         category: category,
         summary: summary,
         sentiment: sentiment,
         content: content,
       );

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

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
      content: article.content,
    );
  }

  // For NewsAPI response
  factory ArticleModel.fromNewsApiJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'],
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: DateTime.parse(
        json['publishedAt'] ?? DateTime.now().toIso8601String(),
      ),
      category: Category.technology,
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
    String? content,
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
      content: content ?? this.content,
    );
  }
}

DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
String _dateTimeToJson(DateTime date) => date.toIso8601String();
