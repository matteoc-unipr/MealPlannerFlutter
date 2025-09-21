import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:path/path.dart' as p;

/// Lightweight accessor around the shared seed data shipped with the project.
class SeedFoodRepository {
  SeedFoodRepository._() {
    _loadSeedData();
  }

  static final SeedFoodRepository instance = SeedFoodRepository._();

  late final Map<String, FoodItem> _itemsById;
  late final Map<String, Nutrients> _per100gById;

  List<FoodItem> get items => _itemsById.values.toList(growable: false);

  FoodItem? itemById(String id) => _itemsById[id];

  FoodItem? itemByName(String name) {
    final lower = name.toLowerCase();
    for (final item in _itemsById.values) {
      if (item.name.toLowerCase() == lower) {
        return item;
      }
    }
    for (final item in _itemsById.values) {
      if (item.name.toLowerCase().contains(lower)) {
        return item;
      }
    }
    return null;
  }

  Nutrients? per100gFor(String id) => _per100gById[id];

  void _loadSeedData() {
    final file = _resolveSeedFile();
    if (file == null) {
      throw StateError('Unable to locate seed_data.json');
    }
    final jsonData = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final foods = jsonData['foodItems'] as List<dynamic>? ?? <dynamic>[];

    _itemsById = <String, FoodItem>{};
    _per100gById = <String, Nutrients>{};

    for (final dynamic entry in foods) {
      final foodJson = entry as Map<String, dynamic>;
      final food = _parseFoodItem(foodJson);
      _itemsById[food.id] = food;

      final per100g = _derivePer100g(food);
      if (per100g != null) {
        _per100gById[food.id] = per100g;
      }
    }
  }

  File? _resolveSeedFile() {
    final candidates = <String>[
      p.join('packages', 'core_kit', 'seed', 'seed_data.json'),
      p.join('..', 'core_kit', 'seed', 'seed_data.json'),
      p.join('..', '..', 'core_kit', 'seed', 'seed_data.json'),
      p.join('core_kit', 'seed', 'seed_data.json'),
    ];

    for (final candidate in candidates) {
      final file = File(candidate);
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }

  FoodItem _parseFoodItem(Map<String, dynamic> json) {
    final nutrientsJson = json['nutrients'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final tags = _stringList(json['tags']);
    final allergens = _stringList(json['allergens']);

    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
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
      tags: tags,
      allergens: allergens,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Nutrients? _derivePer100g(FoodItem item) {
    if (item.servingSize <= 0) {
      return null;
    }
    if (item.servingUnit == UnitType.gram || item.servingUnit == UnitType.milliliter) {
      final factor = 100 / item.servingSize;
      return _scale(item.nutrients, factor);
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

  List<String> _stringList(dynamic value) {
    if (value is List<dynamic>) {
      return value.map((dynamic entry) => entry.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  Nutrients _scale(Nutrients nutrients, double factor) {
    return Nutrients(
      calories: nutrients.calories * factor,
      protein: nutrients.protein * factor,
      fat: nutrients.fat * factor,
      carbohydrates: nutrients.carbohydrates * factor,
      fiber: nutrients.fiber * factor,
      sugar: nutrients.sugar * factor,
      sodium: nutrients.sodium * factor,
    );
  }
}
