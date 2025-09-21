import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'model_utils.dart';

part 'pantry_item.freezed.dart';
part 'pantry_item.g.dart';

/// Represents an ingredient currently stored by the user.
@freezed
class PantryItem with _$PantryItem {
  const PantryItem._();

  const factory PantryItem({
    required String id,
    required String name,
    required double quantity,
    required UnitType unit,
    @Default(false) bool isStaple,
    DateTime? expiryDate,
    String? notes,
  }) = _PantryItem;

  factory PantryItem.create({
    String? id,
    required String name,
    required double quantity,
    required UnitType unit,
    bool isStaple = false,
    DateTime? expiryDate,
    String? notes,
  }) =>
      PantryItem(
        id: generateId(id),
        name: name,
        quantity: quantity,
        unit: unit,
        isStaple: isStaple,
        expiryDate: expiryDate,
        notes: notes,
      );

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);
}
