import 'package:core_kit/core_kit.dart';

import '../data/seed_repository.dart';
import '../nutrition_provider.dart';

abstract class SeededMockProvider implements NutritionProvider {
  SeededMockProvider({
    SeedFoodRepository? repository,
    required Map<String, String> barcodeToFoodId,
  })  : _repository = repository ?? SeedFoodRepository.instance,
        _catalog = _buildCatalog(
          repository ?? SeedFoodRepository.instance,
          barcodeToFoodId,
        ),
        _itemsById = _buildById(
          repository ?? SeedFoodRepository.instance,
          barcodeToFoodId,
        );

  final SeedFoodRepository _repository;
  final Map<String, FoodItem> _catalog;
  final Map<String, FoodItem> _itemsById;

  static Map<String, FoodItem> _buildCatalog(
    SeedFoodRepository repository,
    Map<String, String> barcodeToFoodId,
  ) {
    final map = <String, FoodItem>{};
    barcodeToFoodId.forEach((barcode, foodId) {
      final item = repository.itemById(foodId);
      if (item != null) {
        map[barcode] = item;
      }
    });
    return map;
  }

  static Map<String, FoodItem> _buildById(
    SeedFoodRepository repository,
    Map<String, String> barcodeToFoodId,
  ) {
    final byId = <String, FoodItem>{};
    barcodeToFoodId.forEach((_, foodId) {
      final item = repository.itemById(foodId);
      if (item != null) {
        byId[item.id] = item;
      }
    });
    return byId;
  }

  @override
  Future<FoodItem?> lookupByBarcode(String barcode) async => _catalog[barcode];

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _catalog.values.toList(growable: false);
    }
    final matches = _catalog.values.where((item) {
      final name = item.name.toLowerCase();
      if (name.contains(normalized)) {
        return true;
      }
      for (final tag in item.tags) {
        if (tag.toLowerCase().contains(normalized)) {
          return true;
        }
      }
      return false;
    }).toList(growable: false);
    matches.sort((a, b) => a.name.compareTo(b.name));
    return matches;
  }

  @override
  Future<Nutrients?> nutrientsFor(FoodItem item) async => _itemsById[item.id]?.nutrients;

  Iterable<FoodItem> get catalog => _catalog.values;

  SeedFoodRepository get repository => _repository;
}
