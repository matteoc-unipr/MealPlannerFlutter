import 'package:core_kit/core_kit.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:test/test.dart';

class _CountingProvider implements NutritionProvider {
  _CountingProvider(
      {this.lookupResult,
      this.searchResult = const <FoodItem>[],
      this.nutrients});

  final FoodItem? lookupResult;
  final List<FoodItem> searchResult;
  final Nutrients? nutrients;

  int lookupCalls = 0;
  int searchCalls = 0;
  int nutrientCalls = 0;

  @override
  Future<FoodItem?> lookupByBarcode(String barcode) async {
    lookupCalls += 1;
    return lookupResult;
  }

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    searchCalls += 1;
    return searchResult;
  }

  @override
  Future<Nutrients?> nutrientsFor(FoodItem item) async {
    nutrientCalls += 1;
    return nutrients;
  }
}

void main() {
  group('CompositeNutritionProvider', () {
    test('queries providers sequentially and caches lookup results', () async {
      final quinoa = FoodItem.create(
        name: 'Quinoa',
        nutrients: const Nutrients(calories: 222, protein: 8),
        servingSize: 100,
        servingUnit: UnitType.gram,
      );

      final first = _CountingProvider();
      final second = _CountingProvider(lookupResult: quinoa);

      final provider = CompositeNutritionProvider(
        providers: <NutritionProvider>[first, second],
      );

      final firstCall = await provider.lookupByBarcode('123');
      final secondCall = await provider.lookupByBarcode('123');

      expect(firstCall, quinoa);
      expect(secondCall, quinoa);
      expect(first.lookupCalls, 1);
      expect(second.lookupCalls, 1);
    });

    test('falls back to manual catalog when providers miss', () async {
      final provider =
          CompositeNutritionProvider(providers: const <NutritionProvider>[]);

      final bread = await provider.lookupByBarcode('036000291452');

      expect(bread, isNotNull);
      expect(bread!.name.toLowerCase(), contains('bread'));
    });

    test('searchFoods respects provider order and caches responses', () async {
      final yogurt = FoodItem.create(
        name: 'Greek Yogurt',
        nutrients: const Nutrients(calories: 120),
        servingSize: 1,
        servingUnit: UnitType.serving,
      );

      final first = _CountingProvider(searchResult: <FoodItem>[yogurt]);
      final provider = CompositeNutritionProvider(
        providers: <NutritionProvider>[first],
      );

      final resultA = await provider.searchFoods('yogurt');
      final resultB = await provider.searchFoods('  YOgurT ');

      expect(resultA, isNotEmpty);
      expect(resultA.single.name, 'Greek Yogurt');
      expect(resultB.single.name, 'Greek Yogurt');
      expect(first.searchCalls, 1, reason: 'second call should hit the cache');
    });

    test('nutrientsFor falls back to manual data when providers return null',
        () async {
      final manualProvider = CompositeNutritionProvider(
        providers: const <NutritionProvider>[],
      );

      final bread = await manualProvider.lookupByBarcode('036000291452');
      expect(bread, isNotNull);

      final nutrients = await manualProvider.nutrientsFor(bread!);
      expect(nutrients, bread.nutrients);
    });
  });
}
