import 'category.dart';

class UserPreferences {
  final List<Category> preferredCategories;
  final Map<Category, int> categoryWeights; // for personalization

  UserPreferences({
    required this.preferredCategories,
    this.categoryWeights = const {},
  });

  UserPreferences copyWith({
    List<Category>? preferredCategories,
    Map<Category, int>? categoryWeights,
  }) {
    return UserPreferences(
      preferredCategories: preferredCategories ?? this.preferredCategories,
      categoryWeights: categoryWeights ?? this.categoryWeights,
    );
  }
}
