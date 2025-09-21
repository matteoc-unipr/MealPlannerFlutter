import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:path/path.dart' as p;

/// Loads the bundled recipe catalog used by the demo application.
class SeedRecipesRepository {
  SeedRecipesRepository._() {
    _loadSeedData();
  }

  /// Singleton accessor to keep disk reads minimal during tests.
  static final SeedRecipesRepository instance = SeedRecipesRepository._();

  late final Map<String, Recipe> _recipesById;

  /// All recipes available in the seed catalog.
  List<Recipe> get recipes => _recipesById.values.toList(growable: false);

  /// Returns the recipe identified by [id] if present in the catalog.
  Recipe? recipeById(String id) => _recipesById[id];

  /// Performs a very small search over the seed catalog using [query].
  List<Recipe> search(String query) {
    if (query.trim().isEmpty) {
      return recipes;
    }
    final lower = query.toLowerCase();
    return recipes
        .where((recipe) =>
            recipe.title.toLowerCase().contains(lower) ||
            recipe.tags.any((tag) => tag.toLowerCase().contains(lower)))
        .toList(growable: false);
  }

  void _loadSeedData() {
    final file = _resolveSeedFile();
    if (file == null) {
      throw StateError('Unable to locate recipes seed file.');
    }
    final jsonData =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final recipesJson = jsonData['recipes'] as List<dynamic>? ?? <dynamic>[];

    _recipesById = <String, Recipe>{};
    for (final dynamic entry in recipesJson) {
      final recipeJson = entry as Map<String, dynamic>;
      final recipe = _parseRecipe(recipeJson);
      _recipesById[recipe.id] = recipe;
    }
  }

  File? _resolveSeedFile() {
    final candidates = <String>[
      p.join('packages', 'features', 'recipes', 'seed', 'recipes.json'),
      p.join('..', 'features', 'recipes', 'seed', 'recipes.json'),
      p.join('seed', 'recipes.json'),
      p.join('recipes', 'seed', 'recipes.json'),
    ];
    for (final candidate in candidates) {
      final file = File(candidate);
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }

  Recipe _parseRecipe(Map<String, dynamic> json) {
    final nutrientsJson =
        json['nutrients'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final ingredientsJson =
        json['ingredients'] as List<dynamic>? ?? <dynamic>[];
    final instructions =
        _stringList(json['instructions']);
    final tags = _stringList(json['tags']);

    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      nutrients: Nutrients(
        calories: _toDouble(nutrientsJson['calories']),
        protein: _toDouble(nutrientsJson['protein']),
        fat: _toDouble(nutrientsJson['fat']),
        carbohydrates: _toDouble(nutrientsJson['carbohydrates']),
        fiber: _toDouble(nutrientsJson['fiber']),
        sugar: _toDouble(nutrientsJson['sugar']),
        sodium: _toDouble(nutrientsJson['sodium']),
      ),
      servingSize: _toDouble(json['servingSize']),
      servingUnit: UnitType.values.byName(json['servingUnit'] as String),
      ingredients: ingredientsJson
          .map((dynamic ingredient) =>
              _parseIngredient(ingredient as Map<String, dynamic>, json['id']))
          .toList(growable: false),
      instructions: instructions,
      tags: tags,
      prepTimeMinutes: _toInt(json['prepTimeMinutes']),
      cookTimeMinutes: _toInt(json['cookTimeMinutes']),
      imageUrl: json['imageUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  Ingredient _parseIngredient(
    Map<String, dynamic> json,
    String recipeId,
  ) {
    final itemId = json['itemId'] as String?;
    final itemJson = json['item'] as Map<String, dynamic>?;
    final foodItem = _resolveFoodItem(itemId, itemJson);

    if (foodItem == null) {
      throw StateError(
        'Unable to resolve ingredient food item for recipe $recipeId.',
      );
    }

    return Ingredient(
      id: json['id'] as String,
      item: foodItem,
      quantity: _toDouble(json['quantity']),
      unit: UnitType.values.byName(json['unit'] as String),
      preparation: json['preparation'] as String?,
    );
  }

  FoodItem? _resolveFoodItem(String? itemId, Map<String, dynamic>? itemJson) {
    if (itemJson != null) {
      return FoodItem.fromJson(itemJson);
    }
    if (itemId != null) {
      return SeedFoodRepository.instance.itemById(itemId);
    }
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  List<String> _stringList(dynamic value) {
    if (value is List<dynamic>) {
      return value.map((dynamic item) => item.toString()).toList();
    }
    return const <String>[];
  }
}
