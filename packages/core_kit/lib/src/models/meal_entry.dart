import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'ingredient.dart';
import 'model_utils.dart';

part 'meal_entry.freezed.dart';
part 'meal_entry.g.dart';

/// A planned or logged meal for a user.
@freezed
class MealEntry with _$MealEntry {
  const MealEntry._();

  const factory MealEntry({
    required String id,
    required MealType mealType,
    required DateTime consumedAt,
    @Default(<Ingredient>[]) List<Ingredient> ingredients,
    String? recipeId,
    double? servings,
    String? notes,
  }) = _MealEntry;

  factory MealEntry.create({
    String? id,
    required MealType mealType,
    required DateTime consumedAt,
    List<Ingredient>? ingredients,
    String? recipeId,
    double? servings,
    String? notes,
  }) =>
      MealEntry(
        id: generateId(id),
        mealType: mealType,
        consumedAt: consumedAt,
        ingredients: ingredients ?? const <Ingredient>[],
        recipeId: recipeId,
        servings: servings,
        notes: notes,
      );

  factory MealEntry.fromJson(Map<String, dynamic> json) =>
      _$MealEntryFromJson(json);
}
