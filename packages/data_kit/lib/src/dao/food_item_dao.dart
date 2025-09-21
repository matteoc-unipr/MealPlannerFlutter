import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:drift/drift.dart';

import 'dao_helpers.dart';

class FoodItemDao {
  FoodItemDao(this._db);

  final AppDatabase _db;

  Future<void> upsertFoodItem(FoodItem item) async {
    await _db.into(_db.foodItems).insert(
          MapInsertable(_db.foodItemToColumns(item)),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> insertAll(Iterable<FoodItem> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.foodItems,
        items.map((item) => MapInsertable(_db.foodItemToColumns(item))).toList(),
      );
    });
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final rows = await _db
        .customSelect('SELECT * FROM food_items ORDER BY name ASC',
            readsFrom: {_db.foodItems})
        .get();
    return rows.map((row) => _db.mapFoodItem(rowToMap(row))).toList();
  }

  Stream<List<FoodItem>> watchAllFoodItems() {
    final query = _db.customSelect(
      'SELECT * FROM food_items ORDER BY name ASC',
      readsFrom: {_db.foodItems},
    );
    return query.watch().map(
          (rows) => rows.map((row) => _db.mapFoodItem(rowToMap(row))).toList(),
        );
  }

  Future<FoodItem?> getFoodItem(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM food_items WHERE id = ? LIMIT 1',
          variables: [Variable<String>(id)],
          readsFrom: {_db.foodItems},
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _db.mapFoodItem(rowToMap(row));
  }

  Future<int> deleteFoodItem(String id) {
    return _db.customUpdate(
      'DELETE FROM food_items WHERE id = ?',
      variables: [Variable<String>(id)],
      updates: {_db.foodItems},
    );
  }

  Future<void> clear() {
    return _db.customStatement(
      'DELETE FROM food_items',
      updates: {_db.foodItems},
    );
  }
}
