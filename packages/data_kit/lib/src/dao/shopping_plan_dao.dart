import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:drift/drift.dart';

import 'dao_helpers.dart';

class ShoppingPlanDao {
  ShoppingPlanDao(this._db);

  final AppDatabase _db;

  static const _itemsSql = '''
SELECT
  p.id AS item_id,
  p.name AS item_name,
  p.quantity AS item_quantity,
  p.unit AS item_unit,
  p.is_staple AS item_is_staple,
  p.expiry_date AS item_expiry_date,
  p.notes AS item_notes,
  p.shopping_plan_id AS item_shopping_plan_id
FROM pantry_items p
WHERE p.shopping_plan_id = ?
ORDER BY p.name ASC
''';

  Future<void> upsertPlan(ShoppingPlan plan) async {
    await _db.transaction(() async {
      await _db.into(_db.shoppingPlans).insert(
            MapInsertable(_db.shoppingPlanToColumns(plan)),
            mode: InsertMode.insertOrReplace,
          );

      await _db.customUpdate(
        'DELETE FROM pantry_items WHERE shopping_plan_id = ?',
        variables: [Variable<String>(plan.id)],
        updates: {_db.pantryItems},
      );

      for (final item in plan.items) {
        final itemMap = _db.pantryItemToColumns(
          item,
          shoppingPlanId: plan.id,
        );
        await _db.into(_db.pantryItems).insert(
              MapInsertable(itemMap),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<ShoppingPlan?> getPlan(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM shopping_plans WHERE id = ? LIMIT 1',
          variables: [Variable<String>(id)],
          readsFrom: {_db.shoppingPlans},
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final items = await _itemsForPlan(id);
    return _db.mapShoppingPlan(rowToMap(row), items: items);
  }

  Future<List<ShoppingPlan>> getPlans() async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM shopping_plans ORDER BY created_at DESC',
          readsFrom: {_db.shoppingPlans},
        )
        .get();
    final results = <ShoppingPlan>[];
    for (final row in rows) {
      final data = rowToMap(row);
      final planId = data['id'] as String;
      final items = await _itemsForPlan(planId);
      results.add(_db.mapShoppingPlan(data, items: items));
    }
    return results;
  }

  Future<List<PantryItem>> _itemsForPlan(String planId) async {
    final rows = await _db
        .customSelect(
          _itemsSql,
          variables: [Variable<String>(planId)],
          readsFrom: {_db.pantryItems},
        )
        .get();
    return rows.map((row) {
      final data = extractWithPrefix(row.data, 'item_');
      return _db.mapPantryItem(data);
    }).toList();
  }

  Future<int> deletePlan(String id) async {
    return _db.transaction(() async {
      await _db.customUpdate(
        'DELETE FROM pantry_items WHERE shopping_plan_id = ?',
        variables: [Variable<String>(id)],
        updates: {_db.pantryItems},
      );
      return _db.customUpdate(
        'DELETE FROM shopping_plans WHERE id = ?',
        variables: [Variable<String>(id)],
        updates: {_db.shoppingPlans},
      );
    });
  }

  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.customStatement(
        'DELETE FROM pantry_items',
        updates: {_db.pantryItems},
      );
      await _db.customStatement(
        'DELETE FROM shopping_plans',
        updates: {_db.shoppingPlans},
      );
    });
  }
}
