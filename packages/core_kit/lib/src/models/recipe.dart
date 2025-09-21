import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'ingredient.dart';
import 'model_utils.dart';
import 'nutrients.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

/// A composed meal with instructions and nutrient metadata.
@freezed
class Recipe with _$Recipe {
  const Recipe._();

  const factory Recipe({
    required String id,
    required String title,
    required String description,
    required Nutrients nutrients,
    required double servingSize,
    required UnitType servingUnit,
    @Default(<Ingredient>[]) List<Ingredient> ingredients,
    @Default(<String>[]) List<String> instructions,
    @Default(<String>[]) List<String> tags,
    @Default(0) int prepTimeMinutes,
    @Default(0) int cookTimeMinutes,
    String? imageUrl,
    String? sourceUrl,
  }) = _Recipe;

  factory Recipe.create({
    String? id,
    required String title,
    required String description,
    required Nutrients nutrients,
    required double servingSize,
    required UnitType servingUnit,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<String>? tags,
    int prepTimeMinutes = 0,
    int cookTimeMinutes = 0,
    String? imageUrl,
    String? sourceUrl,
  }) =>
      Recipe(
        id: generateId(id),
        title: title,
        description: description,
        nutrients: nutrients,
        servingSize: servingSize,
        servingUnit: servingUnit,
        ingredients: ingredients ?? const <Ingredient>[],
        instructions: instructions ?? const <String>[],
        tags: tags ?? const <String>[],
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        imageUrl: imageUrl,
        sourceUrl: sourceUrl,
      );

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
