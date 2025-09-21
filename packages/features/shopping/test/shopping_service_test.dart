import 'package:core_kit/core_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_feature/shopping_feature.dart';

void main() {
  group('ShoppingService', () {
    test('aggregates ingredients until next shopping day', () {
      final service = ShoppingService(now: () => DateTime.utc(2024, 1, 1));
      final profile = UserProfile.create(
        name: 'Anna',
        preferredDiet: DietModel.omnivore,
        shoppingDay: Weekday.thursday,
        dailyCalorieTarget: 2000,
        heightCm: 168,
        weightKg: 62,
        createdAt: DateTime.utc(2023, 12, 1),
        updatedAt: DateTime.utc(2023, 12, 31),
      );

      final apple = FoodItem(
        id: 'apple',
        name: 'Apple',
        nutrients: const Nutrients(calories: 95),
        servingSize: 1,
        servingUnit: UnitType.piece,
      );
      final banana = FoodItem(
        id: 'banana',
        name: 'Banana',
        nutrients: const Nutrients(calories: 100),
        servingSize: 1,
        servingUnit: UnitType.piece,
      );

      MealEntry _entry(DateTime day, Ingredient ingredient) {
        return MealEntry(
          id: '${ingredient.item.id}-${day.toIso8601String()}',
          mealType: MealType.breakfast,
          consumedAt: day,
          ingredients: <Ingredient>[ingredient],
        );
      }

      final plannedMeals = <MealEntry>[
        _entry(
          DateTime.utc(2024, 1, 1, 8),
          Ingredient(
            id: 'ing-apple-1',
            item: apple,
            quantity: 2,
            unit: UnitType.piece,
          ),
        ),
        _entry(
          DateTime.utc(2024, 1, 3, 8),
          Ingredient(
            id: 'ing-banana-1',
            item: banana,
            quantity: 3,
            unit: UnitType.piece,
          ),
        ),
        // Falls on the shopping day and should be excluded.
        _entry(
          DateTime.utc(2024, 1, 4, 8),
          Ingredient(
            id: 'ing-apple-2',
            item: apple,
            quantity: 1,
            unit: UnitType.piece,
          ),
        ),
      ];

      final summary = service.buildSummary(
        plannedMeals: plannedMeals,
        profile: profile,
        planStart: DateTime.utc(2024, 1, 1),
      );

      expect(summary.plan.items, hasLength(2));
      expect(summary.plan.items.firstWhere((item) => item.name == 'Apple').quantity, 2);
      expect(summary.nextShoppingDate.weekday, DateTime.thursday);
    });
  });
}
