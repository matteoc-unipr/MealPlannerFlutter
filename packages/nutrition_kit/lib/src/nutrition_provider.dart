import 'package:core_kit/core_kit.dart';

/// Contract for retrieving nutrition information from third party sources.
abstract class NutritionProvider {
  /// Looks up a food entry by [barcode]. Returns `null` when the provider does
  /// not have a matching product in its catalog.
  Future<FoodItem?> lookupByBarcode(String barcode);

  /// Performs a text search for foods matching [query].
  Future<List<FoodItem>> searchFoods(String query);

  /// Retrieves the most up to date nutrient profile for [item].
  Future<Nutrients?> nutrientsFor(FoodItem item);
}
