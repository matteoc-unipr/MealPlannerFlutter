import 'package:core_kit/core_kit.dart';

import '../data/seed_repository.dart';

/// Computes the nutrient totals for a [FoodItem] given a [quantity] and [unit].
Nutrients computeNutrients(
  FoodItem item,
  double quantity,
  UnitType unit,
) {
  if (quantity <= 0) {
    return const Nutrients();
  }

  final per100g = _per100gFor(item);
  final grams = _quantityInGrams(quantity, unit, item);

  if (per100g != null && grams != null) {
    final factor = grams / 100;
    return per100g.scale(factor);
  }

  final servings = _quantityInServings(quantity, unit, item);
  return item.nutrients.scale(servings);
}

Nutrients? _per100gFor(FoodItem item) {
  final repository = SeedFoodRepository.instance;
  final seeded = repository.per100gFor(item.id);
  if (seeded != null) {
    return seeded;
  }
  if (_isWeightUnit(item.servingUnit) && item.servingSize > 0) {
    final factor = 100 / item.servingSize;
    return item.nutrients.scale(factor);
  }
  return null;
}

bool _isWeightUnit(UnitType unit) {
  return unit == UnitType.gram || unit == UnitType.milliliter;
}

const Map<UnitType, double> _gramsPerUnit = <UnitType, double>{
  UnitType.gram: 1.0,
  UnitType.milliliter: 1.0,
  UnitType.ounce: 28.3495,
  UnitType.pound: 453.592,
  UnitType.cup: 240.0,
  UnitType.tablespoon: 15.0,
  UnitType.teaspoon: 5.0,
};

double? _quantityInGrams(double quantity, UnitType unit, FoodItem item) {
  final grams = _gramsPerUnit[unit];
  if (grams != null) {
    return quantity * grams;
  }
  if (unit == UnitType.serving &&
      _isWeightUnit(item.servingUnit) &&
      item.servingSize > 0) {
    return quantity * item.servingSize;
  }
  if (unit == item.servingUnit &&
      _gramsPerUnit.containsKey(unit) &&
      item.servingSize > 0) {
    return quantity * item.servingSize;
  }
  return null;
}

double _quantityInServings(double quantity, UnitType unit, FoodItem item) {
  if (unit == UnitType.serving) {
    return quantity;
  }
  if (unit == item.servingUnit) {
    if (item.servingSize == 0) {
      return 0;
    }
    return quantity / item.servingSize;
  }

  final grams = _quantityInGrams(quantity, unit, item);
  if (grams != null &&
      _isWeightUnit(item.servingUnit) &&
      item.servingSize > 0) {
    return grams / item.servingSize;
  }

  return quantity;
}

extension on Nutrients {
  Nutrients scale(double factor) {
    return Nutrients(
      calories: calories * factor,
      protein: protein * factor,
      fat: fat * factor,
      carbohydrates: carbohydrates * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
    );
  }
}
