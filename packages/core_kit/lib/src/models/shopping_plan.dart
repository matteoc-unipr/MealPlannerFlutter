import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'model_utils.dart';
import 'pantry_item.dart';

part 'shopping_plan.freezed.dart';
part 'shopping_plan.g.dart';

/// Weekly shopping lists aligned with the meal planner.
@freezed
class ShoppingPlan with _$ShoppingPlan {
  const ShoppingPlan._();

  const factory ShoppingPlan({
    required String id,
    required Weekday weekStart,
    required PlanStatus status,
    required DateTime createdAt,
    @Default(<PantryItem>[]) List<PantryItem> items,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? notes,
  }) = _ShoppingPlan;

  factory ShoppingPlan.create({
    String? id,
    required Weekday weekStart,
    required PlanStatus status,
    required DateTime createdAt,
    List<PantryItem>? items,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? notes,
  }) =>
      ShoppingPlan(
        id: generateId(id),
        weekStart: weekStart,
        status: status,
        createdAt: createdAt,
        items: items ?? const <PantryItem>[],
        updatedAt: updatedAt,
        completedAt: completedAt,
        notes: notes,
      );

  factory ShoppingPlan.fromJson(Map<String, dynamic> json) =>
      _$ShoppingPlanFromJson(json);
}
