import 'dart:collection';

import 'package:core_kit/core_kit.dart';

import 'data/seed_repository.dart';
import 'nutrition_provider.dart';
import 'providers/edamam_mock.dart';
import 'providers/food_data_central_mock.dart';
import 'providers/open_food_facts_mock.dart';

/// Aggregates multiple nutrition providers and caches responses in-memory.
class CompositeNutritionProvider implements NutritionProvider {
  CompositeNutritionProvider({
    List<NutritionProvider>? providers,
    int cacheSize = 32,
    Map<String, FoodItem>? manualCatalog,
  })  : _providers = List<NutritionProvider>.unmodifiable(
          providers ??
              <NutritionProvider>[
                OpenFoodFactsMockProvider(),
                FoodDataCentralMockProvider(),
                EdamamMockProvider(),
              ],
        ),
        _lookupCache = _LruCache<String, FoodItem>(capacity: cacheSize),
        _searchCache = _LruCache<String, List<FoodItem>>(capacity: cacheSize),
        _nutrientCache = _LruCache<String, Nutrients>(capacity: cacheSize),
        _manualCatalog = Map<String, FoodItem>.unmodifiable(
          manualCatalog ??
              _defaultManualCatalog(
                SeedFoodRepository.instance,
              ),
        ) {
    _manualById = Map<String, FoodItem>.unmodifiable({
      for (final item in _manualCatalog.values) item.id: item,
    });
  }

  final List<NutritionProvider> _providers;
  final _LruCache<String, FoodItem> _lookupCache;
  final _LruCache<String, List<FoodItem>> _searchCache;
  final _LruCache<String, Nutrients> _nutrientCache;
  final Map<String, FoodItem> _manualCatalog;
  late final Map<String, FoodItem> _manualById;

  static Map<String, FoodItem> _defaultManualCatalog(
    SeedFoodRepository repository,
  ) {
    final map = <String, FoodItem>{};
    final bread = repository.itemById(
      '77777777-7777-7777-7777-777777777777',
    );
    if (bread != null) {
      map['036000291452'] = bread;
    }
    return map;
  }

  @override
  Future<FoodItem?> lookupByBarcode(String barcode) async {
    final cached = _lookupCache.get(barcode);
    if (cached != null) {
      return cached;
    }

    for (final provider in _providers) {
      final result = await provider.lookupByBarcode(barcode);
      if (result != null) {
        _lookupCache.set(barcode, result);
        return result;
      }
    }

    final manual = _manualCatalog[barcode];
    if (manual != null) {
      _lookupCache.set(barcode, manual);
    }
    return manual;
  }

  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    final key = query.trim().toLowerCase();
    final cached = _searchCache.get(key);
    if (cached != null) {
      return cached;
    }

    for (final provider in _providers) {
      final result = await provider.searchFoods(query);
      if (result.isNotEmpty) {
        final copy = List<FoodItem>.unmodifiable(result);
        _searchCache.set(key, copy);
        return copy;
      }
    }

    final manualMatches = _manualCatalog.values.where(
      (item) => _matchesQuery(item, key),
    ).toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    final manualResult = List<FoodItem>.unmodifiable(manualMatches);
    _searchCache.set(key, manualResult);
    return manualResult;
  }

  @override
  Future<Nutrients?> nutrientsFor(FoodItem item) async {
    final cached = _nutrientCache.get(item.id);
    if (cached != null) {
      return cached;
    }

    for (final provider in _providers) {
      final result = await provider.nutrientsFor(item);
      if (result != null) {
        _nutrientCache.set(item.id, result);
        return result;
      }
    }

    final manual = _manualById[item.id] ?? item;
    _nutrientCache.set(item.id, manual.nutrients);
    return manual.nutrients;
  }

  bool _matchesQuery(FoodItem item, String query) {
    if (query.isEmpty) {
      return true;
    }
    final name = item.name.toLowerCase();
    if (name.contains(query)) {
      return true;
    }
    for (final tag in item.tags) {
      if (tag.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }
}

class _LruCache<K, V> {
  _LruCache({required this.capacity}) : assert(capacity > 0);

  final int capacity;
  final _store = LinkedHashMap<K, V>();

  V? get(K key) {
    if (!_store.containsKey(key)) {
      return null;
    }
    final value = _store.remove(key)!;
    _store[key] = value;
    return value;
  }

  void set(K key, V value) {
    if (_store.containsKey(key)) {
      _store.remove(key);
    } else if (_store.length >= capacity) {
      final oldestKey = _store.keys.first;
      _store.remove(oldestKey);
    }
    _store[key] = value;
  }
}
