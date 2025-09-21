import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'food_item.dart';
import 'model_utils.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

/// Links a [FoodItem] with a specific quantity for recipes and meals.
@freezed
class Ingredient with _$Ingredient {
  const Ingredient._();

  const factory Ingredient({
    required String id,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
    String? preparation,
  }) = _Ingredient;

  factory Ingredient.create({
    String? id,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
    String? preparation,
  }) =>
      Ingredient(
        id: generateId(id),
        item: item,
        quantity: quantity,
        unit: unit,
        preparation: preparation,
      );

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}
