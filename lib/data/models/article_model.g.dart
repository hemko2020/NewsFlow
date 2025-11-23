// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleModel _$ArticleModelFromJson(Map<String, dynamic> json) => ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: _dateTimeFromJson(json['publishedAt'] as String),
      category: $enumDecode(_$CategoryEnumMap, json['category'],
          unknownValue: Category.technology),
      summary: json['summary'] as String?,
      sentiment: json['sentiment'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$ArticleModelToJson(ArticleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'source': instance.source,
      'imageUrl': instance.imageUrl,
      'publishedAt': _dateTimeToJson(instance.publishedAt),
      'category': _$CategoryEnumMap[instance.category]!,
      'summary': instance.summary,
      'sentiment': instance.sentiment,
      'content': instance.content,
    };

const _$CategoryEnumMap = {
  Category.general: 'general',
  Category.finance: 'finance',
  Category.health: 'health',
  Category.sciences: 'sciences',
  Category.technology: 'technology',
  Category.sports: 'sports',
  Category.entertainment: 'entertainment',
};
