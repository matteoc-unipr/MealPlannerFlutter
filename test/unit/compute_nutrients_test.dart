import 'package:core_kit/core_kit.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:nutrition_kit/src/data/seed_repository.dart';
import 'package:test/test.dart';

void main() {
  group('computeNutrients', () {
    late SeedFoodRepository repository;

    setUp(() {
      repository = SeedFoodRepository.instance;
    });

    test('uses per-100g data when available from the seed repository', () {
      final quinoa = repository.itemByName('Quinoa');
      expect(quinoa, isNotNull, reason: 'seed data should contain quinoa');

      final nutrients = computeNutrients(quinoa!, 150, UnitType.gram);
      final per100g = repository.per100gFor(quinoa.id);
      expect(per100g, isNotNull);

      final expected = Nutrients(
        calories: per100g!.calories * 1.5,
        protein: per100g.protein * 1.5,
        fat: per100g.fat * 1.5,
        carbohydrates: per100g.carbohydrates * 1.5,
        fiber: per100g.fiber * 1.5,
        sugar: per100g.sugar * 1.5,
        sodium: per100g.sodium * 1.5,
      );

      expect(nutrients.calories, closeTo(expected.calories, 0.0001));
      expect(nutrients.protein, closeTo(expected.protein, 0.0001));
      expect(nutrients.carbohydrates, closeTo(expected.carbohydrates, 0.0001));
    });

    test('falls back to serving based computations when needed', () {
      final snack = FoodItem.create(
        name: 'Trail mix',
        nutrients: const Nutrients(
          calories: 210,
          protein: 7,
          fat: 11,
          carbohydrates: 22,
          fiber: 4,
          sugar: 14,
          sodium: 130,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
      );

      final nutrients = computeNutrients(snack, 2.5, UnitType.serving);

      expect(nutrients.calories, closeTo(525, 0.0001));
      expect(nutrients.protein, closeTo(17.5, 0.0001));
      expect(nutrients.fat, closeTo(27.5, 0.0001));
    });

    test('returns zero nutrients for non-positive quantities', () {
      final apple = repository.itemByName('Apple');
      expect(apple, isNotNull);

      final zero = computeNutrients(apple!, 0, UnitType.gram);
      expect(zero.calories, 0);
      expect(zero.protein, 0);

      final negative = computeNutrients(apple, -10, UnitType.gram);
      expect(negative.calories, 0);
      expect(negative.protein, 0);
    });
  });
}
