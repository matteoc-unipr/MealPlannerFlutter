import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:drift/drift.dart';

import 'dao_helpers.dart';

class MealEntryDao {
  MealEntryDao(this._db);

  final AppDatabase _db;

  static const _ingredientJoinSql = '''
SELECT
  i.id AS ingredient_id,
  i.food_item_id AS ingredient_food_item_id,
  i.quantity AS ingredient_quantity,
  i.unit AS ingredient_unit,
  i.preparation AS ingredient_preparation,
  i.recipe_id AS ingredient_recipe_id,
  i.meal_entry_id AS ingredient_meal_entry_id,
  f.id AS food_id,
  f.name AS food_name,
  f.calories AS food_calories,
  f.protein AS food_protein,
  f.fat AS food_fat,
  f.carbohydrates AS food_carbohydrates,
  f.fiber AS food_fiber,
  f.sugar AS food_sugar,
  f.sodium AS food_sodium,
  f.serving_size AS food_serving_size,
  f.serving_unit AS food_serving_unit,
  f.tags AS food_tags,
  f.allergens AS food_allergens,
  f.brand AS food_brand,
  f.description AS food_description,
  f.image_url AS food_image_url
FROM ingredients i
INNER JOIN food_items f ON f.id = i.food_item_id
WHERE i.meal_entry_id = ?
ORDER BY i.id ASC
''';

  Future<void> upsertMealEntry(MealEntry entry) async {
    await _db.transaction(() async {
      await _db.into(_db.mealEntries).insert(
            MapInsertable(_db.mealEntryToColumns(entry)),
            mode: InsertMode.insertOrReplace,
          );

      await _db.customUpdate(
        'DELETE FROM ingredients WHERE meal_entry_id = ?',
        variables: [Variable<String>(entry.id)],
        updates: {_db.ingredients},
      );

      for (final ingredient in entry.ingredients) {
        final ingredientMap = _db.ingredientToColumns(
          ingredient,
          mealEntryId: entry.id,
          recipeId: entry.recipeId,
        );
        await _db.into(_db.ingredients).insert(
              MapInsertable(ingredientMap),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<MealEntry?> getMealEntry(String id) async {
    final row = await _db
        .customSelect(
          'SELECT * FROM meal_entries WHERE id = ? LIMIT 1',
          variables: [Variable<String>(id)],
          readsFrom: {_db.mealEntries},
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final ingredients = await _ingredientsForEntry(id);
    return _db.mapMealEntry(rowToMap(row), ingredients: ingredients);
  }

  Future<List<MealEntry>> getMealEntries() async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM meal_entries ORDER BY consumed_at DESC',
          readsFrom: {_db.mealEntries},
        )
        .get();
    final results = <MealEntry>[];
    for (final row in rows) {
      final data = rowToMap(row);
      final entryId = data['id'] as String;
      final ingredients = await _ingredientsForEntry(entryId);
      results.add(_db.mapMealEntry(data, ingredients: ingredients));
    }
    return results;
  }

  Future<List<Ingredient>> _ingredientsForEntry(String entryId) async {
    final rows = await _db
        .customSelect(
          _ingredientJoinSql,
          variables: [Variable<String>(entryId)],
          readsFrom: {_db.ingredients, _db.foodItems},
        )
        .get();
    return rows.map((row) {
      final data = row.data;
      final ingredientMap = extractWithPrefix(data, 'ingredient_');
      final foodItemMap = extractWithPrefix(data, 'food_');
      final foodItem = _db.mapFoodItem(foodItemMap);
      return _db.mapIngredient(ingredientMap, foodItem);
    }).toList();
  }

  Future<int> deleteMealEntry(String id) async {
    return _db.transaction(() async {
      await _db.customUpdate(
        'DELETE FROM ingredients WHERE meal_entry_id = ?',
        variables: [Variable<String>(id)],
        updates: {_db.ingredients},
      );
      return _db.customUpdate(
        'DELETE FROM meal_entries WHERE id = ?',
        variables: [Variable<String>(id)],
        updates: {_db.mealEntries},
      );
    });
  }

  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.customStatement(
        'DELETE FROM ingredients',
        updates: {_db.ingredients},
      );
      await _db.customStatement(
        'DELETE FROM meal_entries',
        updates: {_db.mealEntries},
      );
    });
  }
}
