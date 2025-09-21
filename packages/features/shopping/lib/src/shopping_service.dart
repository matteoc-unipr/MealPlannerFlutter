import 'package:core_kit/core_kit.dart';

/// Result of aggregating planned meals into a shopping list.
class ShoppingSummary {
  const ShoppingSummary({
    required this.plan,
    required this.nextShoppingDate,
  });

  /// Shopping plan persisted in the local database.
  final ShoppingPlan plan;

  /// Next shopping date used to schedule notifications.
  final DateTime nextShoppingDate;
}

/// Builds shopping lists aligned with the generated meal plans.
class ShoppingService {
  ShoppingService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Aggregates ingredients required until the next shopping day.
  ShoppingSummary buildSummary({
    required Iterable<MealEntry> plannedMeals,
    required UserProfile profile,
    required DateTime planStart,
    DateTime? reference,
  }) {
    final normalizedStart = _normalize(planStart);
    final generatedAt = _normalize(reference ?? _now());
    final nextShopping = _nextShoppingDate(generatedAt, profile.shoppingDay);

    final relevantMeals = plannedMeals.where((meal) {
      final consumed = meal.consumedAt;
      return !consumed.isBefore(generatedAt) && consumed.isBefore(nextShopping);
    });

    final aggregated = <_AggregationKey, _Aggregation>{};
    for (final meal in relevantMeals) {
      for (final ingredient in meal.ingredients) {
        final key = _AggregationKey(ingredient.item.id, ingredient.unit);
        final existing = aggregated[key];
        if (existing != null) {
          aggregated[key] = existing.addQuantity(ingredient.quantity);
        } else {
          aggregated[key] = _Aggregation(
            name: ingredient.item.name,
            unit: ingredient.unit,
            quantity: ingredient.quantity,
          );
        }
      }
    }

    final items = aggregated.values
        .map((aggregation) => PantryItem.create(
              name: aggregation.name,
              quantity: aggregation.quantity,
              unit: aggregation.unit,
            ))
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    final planId = 'plan-${normalizedStart.toIso8601String()}';
    final plan = ShoppingPlan(
      id: planId,
      weekStart: _weekdayFor(normalizedStart),
      status: PlanStatus.pending,
      createdAt: generatedAt,
      updatedAt: generatedAt,
      items: items,
    );

    return ShoppingSummary(plan: plan, nextShoppingDate: nextShopping);
  }

  /// Computes the next occurrence of the shopping day for [profile].
  DateTime computeNextShoppingDate(UserProfile profile, {DateTime? reference}) {
    return _nextShoppingDate(_normalize(reference ?? _now()), profile.shoppingDay);
  }

  DateTime _nextShoppingDate(DateTime reference, Weekday shoppingDay) {
    final targetWeekday = shoppingDay.index + 1; // DateTime weekday: Monday=1
    final currentWeekday = reference.weekday;
    var delta = targetWeekday - currentWeekday;
    if (delta <= 0) {
      delta += 7;
    }
    return reference.add(Duration(days: delta));
  }

  Weekday _weekdayFor(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return Weekday.monday;
      case DateTime.tuesday:
        return Weekday.tuesday;
      case DateTime.wednesday:
        return Weekday.wednesday;
      case DateTime.thursday:
        return Weekday.thursday;
      case DateTime.friday:
        return Weekday.friday;
      case DateTime.saturday:
        return Weekday.saturday;
      case DateTime.sunday:
      default:
        return Weekday.sunday;
    }
  }

  DateTime _normalize(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _AggregationKey {
  const _AggregationKey(this.itemId, this.unit);

  final String itemId;
  final UnitType unit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AggregationKey &&
        other.itemId == itemId &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(itemId, unit);
}

class _Aggregation {
  const _Aggregation({
    required this.name,
    required this.unit,
    required this.quantity,
  });

  final String name;
  final UnitType unit;
  final double quantity;

  _Aggregation addQuantity(double value) {
    return _Aggregation(name: name, unit: unit, quantity: quantity + value);
  }
}
