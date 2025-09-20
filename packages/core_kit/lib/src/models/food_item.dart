import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'model_utils.dart';
import 'nutrients.dart';

part 'food_item.freezed.dart';
part 'food_item.g.dart';

/// A catalog entry describing a specific ingredient or prepared food.
@freezed
class FoodItem with _$FoodItem {
  const FoodItem._();

  const factory FoodItem({
    required String id,
    required String name,
    required Nutrients nutrients,
    required double servingSize,
    required UnitType servingUnit,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> allergens,
    String? brand,
    String? description,
    String? imageUrl,
  }) = _FoodItem;

  factory FoodItem.create({
    String? id,
    required String name,
    required Nutrients nutrients,
    required double servingSize,
    required UnitType servingUnit,
    List<String>? tags,
    List<String>? allergens,
    String? brand,
    String? description,
    String? imageUrl,
  }) =>
      FoodItem(
        id: generateId(id),
        name: name,
        nutrients: nutrients,
        servingSize: servingSize,
        servingUnit: servingUnit,
        tags: tags ?? const <String>[],
        allergens: allergens ?? const <String>[],
        brand: brand,
        description: description,
        imageUrl: imageUrl,
      );

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
}
