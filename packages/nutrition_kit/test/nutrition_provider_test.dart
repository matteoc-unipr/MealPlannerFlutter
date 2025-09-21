import 'package:core_kit/core_kit.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:nutrition_kit/src/data/seed_repository.dart';
import 'package:test/test.dart';

void main() {
  group('CompositeNutritionProvider', () {
    late CompositeNutritionProvider provider;

    setUp(() {
      provider = CompositeNutritionProvider();
    });

    test('lookupByBarcode queries providers in order', () async {
      final quinoa = await provider.lookupByBarcode('8901234567890');
      expect(quinoa, isNotNull);
      expect(quinoa!.name, 'Quinoa');

      final chicken = await provider.lookupByBarcode('078742300007');
      expect(chicken, isNotNull);
      expect(chicken!.name, 'Grilled Chicken Breast');

      final avocado = await provider.lookupByBarcode('9421902960000');
      expect(avocado, isNotNull);
      expect(avocado!.name, 'Avocado');

      final bread = await provider.lookupByBarcode('036000291452');
      expect(bread, isNotNull);
      expect(bread!.name, 'Whole Grain Bread');
    });

    test('searchFoods falls back between providers and manual data', () async {
      final yogurtResults = await provider.searchFoods('greek');
      expect(yogurtResults.map((item) => item.name), contains('Greek Yogurt'));

      final berries = await provider.searchFoods('blueberries');
      expect(berries.map((item) => item.name), contains('Blueberries'));

      final bread = await provider.searchFoods('bread');
      expect(bread.map((item) => item.name), contains('Whole Grain Bread'));
    });
  });

  group('computeNutrients', () {
    late SeedFoodRepository repository;

    setUp(() {
      repository = SeedFoodRepository.instance;
    });

    test('prefers per-100g data when available', () {
      final quinoa = repository.itemById(
        '11111111-1111-1111-1111-111111111111',
      );
      expect(quinoa, isNotNull);

      final nutrients = computeNutrients(quinoa!, 200, UnitType.gram);
      final caloriesPerGram = quinoa.nutrients.calories / quinoa.servingSize;
      final proteinPerGram = quinoa.nutrients.protein / quinoa.servingSize;
      expect(nutrients.calories, closeTo(caloriesPerGram * 200, 0.01));
      expect(nutrients.protein, closeTo(proteinPerGram * 200, 0.01));
    });

    test('falls back to serving-based calculations', () {
      final snack = FoodItem.create(
        name: 'Trail Mix',
        nutrients: const Nutrients(
          calories: 220,
          protein: 6,
          fat: 12,
          carbohydrates: 24,
          fiber: 3,
          sugar: 12,
          sodium: 150,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
      );

      final nutrients = computeNutrients(snack, 2, UnitType.serving);
      expect(nutrients.calories, 440);
      expect(nutrients.protein, 12);
    });
  });
}
