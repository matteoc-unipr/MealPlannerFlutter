import 'dart:io';

import 'package:core_kit/src/drift/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'dao/food_item_dao.dart';
import 'dao/meal_entry_dao.dart';
import 'dao/shopping_plan_dao.dart';
import 'dao/user_profile_dao.dart';

AppDatabase? _database;

Future<AppDatabase> initDatabase({
  QueryExecutor? executor,
  String? filePath,
  bool reset = false,
  bool logStatements = false,
}) async {
  if (_database != null) {
    if (reset || _database!.isClosed) {
      await _database!.close();
      _database = null;
    } else {
      return _database!;
    }
  }

  final QueryExecutor resolved;
  if (executor != null) {
    resolved = executor;
  } else if (filePath != null) {
    resolved = NativeDatabase(
      File(filePath),
      logStatements: logStatements,
    );
  } else {
    resolved = NativeDatabase.memory(logStatements: logStatements);
  }

  _database = AppDatabase(resolved);
  return _database!;
}

AppDatabase _requireDatabase() {
  final db = _database;
  if (db == null || db.isClosed) {
    throw StateError('Database not initialized. Call initDatabase() first.');
  }
  return db;
}

Future<Map<String, dynamic>> exportJson() async {
  final db = _requireDatabase();
  final foodDao = FoodItemDao(db);
  final mealDao = MealEntryDao(db);
  final profileDao = UserProfileDao(db);
  final planDao = ShoppingPlanDao(db);

  final foods = await foodDao.getAllFoodItems();
  final meals = await mealDao.getMealEntries();
  final profiles = await profileDao.getProfiles();
  final plans = await planDao.getPlans();

  return <String, dynamic>{
    'foodItems': foods.map((item) => item.toJson()).toList(),
    'mealEntries': meals.map((meal) => meal.toJson()).toList(),
    'userProfiles': profiles.map((profile) => profile.toJson()).toList(),
    'shoppingPlans': plans.map((plan) => plan.toJson()).toList(),
  };
}

Future<void> eraseAll() async {
  final db = _requireDatabase();
  await db.transaction(() async {
    await db.customStatement(
      'DELETE FROM ingredients',
      updates: {db.ingredients},
    );
    await db.customStatement(
      'DELETE FROM pantry_items',
      updates: {db.pantryItems},
    );
    await db.customStatement(
      'DELETE FROM meal_entries',
      updates: {db.mealEntries},
    );
    await db.customStatement(
      'DELETE FROM shopping_plans',
      updates: {db.shoppingPlans},
    );
    await db.customStatement(
      'DELETE FROM recipes',
      updates: {db.recipes},
    );
    await db.customStatement(
      'DELETE FROM event_logs',
      updates: {db.eventLogs},
    );
    await db.customStatement(
      'DELETE FROM user_profiles',
      updates: {db.userProfiles},
    );
    await db.customStatement(
      'DELETE FROM food_items',
      updates: {db.foodItems},
    );
  });
}

Future<void> closeDatabase() async {
  if (_database != null && !_database!.isClosed) {
    await _database!.close();
  }
  _database = null;
}
