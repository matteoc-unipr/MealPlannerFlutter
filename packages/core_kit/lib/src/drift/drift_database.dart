import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../models/event_log.dart';
import '../models/food_item.dart';
import '../models/ingredient.dart';
import '../models/meal_entry.dart';
import '../models/nutrients.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../models/shopping_plan.dart';
import '../models/user_profile.dart';
import 'tables.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    FoodItems,
    Recipes,
    MealEntries,
    ShoppingPlans,
    PantryItems,
    UserProfiles,
    EventLogs,
    Ingredients,
  ],
  daos: [
    FoodItemsDao,
    IngredientsDao,
    MealEntriesDao,
    RecipesDao,
    ShoppingPlansDao,
    PantryItemsDao,
    UserProfilesDao,
    EventLogsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 1) {
            await m.createAll();
          }
          if (from < 2) {
            await m.addColumn(userProfiles, userProfiles.shoppingDay);
          }
        },
      );

  List<String> _decodeStringList(dynamic raw) {
    if (raw == null) {
      return const <String>[];
    }
    if (raw is List) {
      return raw.map((dynamic e) => e.toString()).toList();
    }
    if (raw is String && raw.isEmpty) {
      return const <String>[];
    }
    if (raw is String) {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((dynamic e) => e.toString()).toList();
      }
    }
    throw ArgumentError('Unsupported list format: $raw');
  }

  String _encodeStringList(Iterable<String> values) =>
      jsonEncode(List<String>.from(values));

  Map<String, dynamic> _decodeJsonMap(dynamic raw) {
    if (raw == null) {
      return <String, dynamic>{};
    }
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.isEmpty) {
      return <String, dynamic>{};
    }
    if (raw is String) {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw ArgumentError('Unsupported map format: $raw');
  }

  double _doubleValue(dynamic value, [double fallback = 0]) {
    if (value == null) {
      return fallback;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.isNotEmpty) {
      return double.parse(value);
    }
    return fallback;
  }

  int _intValue(dynamic value, [int fallback = 0]) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.isNotEmpty) {
      return int.parse(value);
    }
    return fallback;
  }

  bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  DateTime _decodeDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    throw ArgumentError('Unsupported date format: $value');
  }

  DateTime? _decodeNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return _decodeDateTime(value);
  }

  int _encodeDateTime(DateTime value) => value.millisecondsSinceEpoch;

  int? _encodeNullableDateTime(DateTime? value) =>
      value?.millisecondsSinceEpoch;

  Map<String, dynamic> foodItemToColumns(FoodItem item) => <String, dynamic>{
        'id': item.id,
        'name': item.name,
        'calories': item.nutrients.calories,
        'protein': item.nutrients.protein,
        'fat': item.nutrients.fat,
        'carbohydrates': item.nutrients.carbohydrates,
        'fiber': item.nutrients.fiber,
        'sugar': item.nutrients.sugar,
        'sodium': item.nutrients.sodium,
        'serving_size': item.servingSize,
        'serving_unit': item.servingUnit.name,
        'tags': _encodeStringList(item.tags),
        'allergens': _encodeStringList(item.allergens),
        'brand': item.brand,
        'description': item.description,
        'image_url': item.imageUrl,
      };

  FoodItem mapFoodItem(Map<String, dynamic> data) => FoodItem(
        id: data['id'] as String,
        name: data['name'] as String,
        nutrients: Nutrients(
          calories: _doubleValue(data['calories']),
          protein: _doubleValue(data['protein']),
          fat: _doubleValue(data['fat']),
          carbohydrates: _doubleValue(data['carbohydrates']),
          fiber: _doubleValue(data['fiber']),
          sugar: _doubleValue(data['sugar']),
          sodium: _doubleValue(data['sodium']),
        ),
        servingSize: _doubleValue(data['serving_size']),
        servingUnit: UnitType.values.byName(data['serving_unit'] as String),
        tags: _decodeStringList(data['tags']),
        allergens: _decodeStringList(data['allergens']),
        brand: data['brand'] as String?,
        description: data['description'] as String?,
        imageUrl: data['image_url'] as String?,
      );

  Map<String, dynamic> ingredientToColumns(
    Ingredient ingredient, {
    String? recipeId,
    String? mealEntryId,
  }) =>
      <String, dynamic>{
        'id': ingredient.id,
        'food_item_id': ingredient.item.id,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit.name,
        'preparation': ingredient.preparation,
        'recipe_id': recipeId,
        'meal_entry_id': mealEntryId,
      };

  Ingredient mapIngredient(Map<String, dynamic> data, FoodItem item) =>
      Ingredient(
        id: data['id'] as String,
        item: item,
        quantity: _doubleValue(data['quantity']),
        unit: UnitType.values.byName(data['unit'] as String),
        preparation: data['preparation'] as String?,
      );

  Map<String, dynamic> recipeToColumns(Recipe recipe) => <String, dynamic>{
        'id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'calories': recipe.nutrients.calories,
        'protein': recipe.nutrients.protein,
        'fat': recipe.nutrients.fat,
        'carbohydrates': recipe.nutrients.carbohydrates,
        'fiber': recipe.nutrients.fiber,
        'sugar': recipe.nutrients.sugar,
        'sodium': recipe.nutrients.sodium,
        'serving_size': recipe.servingSize,
        'serving_unit': recipe.servingUnit.name,
        'instructions': _encodeStringList(recipe.instructions),
        'tags': _encodeStringList(recipe.tags),
        'prep_time_minutes': recipe.prepTimeMinutes,
        'cook_time_minutes': recipe.cookTimeMinutes,
        'image_url': recipe.imageUrl,
        'source_url': recipe.sourceUrl,
      };

  Recipe mapRecipe(
    Map<String, dynamic> data, {
    List<Ingredient> ingredients = const <Ingredient>[],
  }) =>
      Recipe(
        id: data['id'] as String,
        title: data['title'] as String,
        description: data['description'] as String,
        nutrients: Nutrients(
          calories: _doubleValue(data['calories']),
          protein: _doubleValue(data['protein']),
          fat: _doubleValue(data['fat']),
          carbohydrates: _doubleValue(data['carbohydrates']),
          fiber: _doubleValue(data['fiber']),
          sugar: _doubleValue(data['sugar']),
          sodium: _doubleValue(data['sodium']),
        ),
        servingSize: _doubleValue(data['serving_size']),
        servingUnit: UnitType.values.byName(data['serving_unit'] as String),
        ingredients: ingredients,
        instructions: _decodeStringList(data['instructions']),
        tags: _decodeStringList(data['tags']),
        prepTimeMinutes: _intValue(data['prep_time_minutes']),
        cookTimeMinutes: _intValue(data['cook_time_minutes']),
        imageUrl: data['image_url'] as String?,
        sourceUrl: data['source_url'] as String?,
      );

  Map<String, dynamic> mealEntryToColumns(MealEntry entry) =>
      <String, dynamic>{
        'id': entry.id,
        'meal_type': entry.mealType.name,
        'consumed_at': _encodeDateTime(entry.consumedAt),
        'recipe_id': entry.recipeId,
        'servings': entry.servings,
        'notes': entry.notes,
      };

  MealEntry mapMealEntry(
    Map<String, dynamic> data, {
    List<Ingredient> ingredients = const <Ingredient>[],
  }) =>
      MealEntry(
        id: data['id'] as String,
        mealType: MealType.values.byName(data['meal_type'] as String),
        consumedAt: _decodeDateTime(data['consumed_at']),
        ingredients: ingredients,
        recipeId: data['recipe_id'] as String?,
        servings: data['servings'] == null
            ? null
            : _doubleValue(data['servings']),
        notes: data['notes'] as String?,
      );

  Map<String, dynamic> shoppingPlanToColumns(ShoppingPlan plan) =>
      <String, dynamic>{
        'id': plan.id,
        'week_start': plan.weekStart.name,
        'status': plan.status.name,
        'created_at': _encodeDateTime(plan.createdAt),
        'updated_at': _encodeNullableDateTime(plan.updatedAt),
        'completed_at': _encodeNullableDateTime(plan.completedAt),
        'notes': plan.notes,
      };

  ShoppingPlan mapShoppingPlan(
    Map<String, dynamic> data, {
    List<PantryItem> items = const <PantryItem>[],
  }) =>
      ShoppingPlan(
        id: data['id'] as String,
        weekStart: Weekday.values.byName(data['week_start'] as String),
        status: PlanStatus.values.byName(data['status'] as String),
        createdAt: _decodeDateTime(data['created_at']),
        updatedAt: _decodeNullableDateTime(data['updated_at']),
        completedAt: _decodeNullableDateTime(data['completed_at']),
        notes: data['notes'] as String?,
        items: items,
      );

  Map<String, dynamic> pantryItemToColumns(
    PantryItem item, {
    String? shoppingPlanId,
  }) =>
      <String, dynamic>{
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit.name,
        'is_staple': item.isStaple ? 1 : 0,
        'expiry_date': _encodeNullableDateTime(item.expiryDate),
        'notes': item.notes,
        'shopping_plan_id': shoppingPlanId,
      };

  PantryItem mapPantryItem(Map<String, dynamic> data) => PantryItem(
        id: data['id'] as String,
        name: data['name'] as String,
        quantity: _doubleValue(data['quantity']),
        unit: UnitType.values.byName(data['unit'] as String),
        isStaple: _boolValue(data['is_staple']),
        expiryDate: _decodeNullableDateTime(data['expiry_date']),
        notes: data['notes'] as String?,
      );

  Map<String, dynamic> userProfileToColumns(UserProfile profile) =>
      <String, dynamic>{
        'id': profile.id,
        'name': profile.name,
        'preferred_diet': profile.preferredDiet.name,
        'shopping_day': profile.shoppingDay.name,
        'daily_calorie_target': profile.dailyCalorieTarget,
        'height_cm': profile.heightCm,
        'weight_kg': profile.weightKg,
        'created_at': _encodeDateTime(profile.createdAt),
        'updated_at': _encodeDateTime(profile.updatedAt),
        'birth_date': _encodeNullableDateTime(profile.birthDate),
        'allergies': _encodeStringList(profile.allergies),
        'disliked_ingredients':
            _encodeStringList(profile.dislikedIngredients),
        'photo_url': profile.photoUrl,
      };

  UserProfile mapUserProfile(Map<String, dynamic> data) => UserProfile(
        id: data['id'] as String,
        name: data['name'] as String,
        preferredDiet:
            DietModel.values.byName(data['preferred_diet'] as String),
        shoppingDay: Weekday.values.byName(data['shopping_day'] as String),
        dailyCalorieTarget: _intValue(data['daily_calorie_target']),
        heightCm: _doubleValue(data['height_cm']),
        weightKg: _doubleValue(data['weight_kg']),
        createdAt: _decodeDateTime(data['created_at']),
        updatedAt: _decodeDateTime(data['updated_at']),
        birthDate: _decodeNullableDateTime(data['birth_date']),
        allergies: _decodeStringList(data['allergies']),
        dislikedIngredients:
            _decodeStringList(data['disliked_ingredients']),
        photoUrl: data['photo_url'] as String?,
      );

  Map<String, dynamic> eventLogToColumns(EventLog log) => <String, dynamic>{
        'id': log.id,
        'timestamp': _encodeDateTime(log.timestamp),
        'type': log.type,
        'description': log.description,
        'metadata': jsonEncode(log.metadata),
        'user_id': log.userId,
      };

  EventLog mapEventLog(Map<String, dynamic> data) => EventLog(
        id: data['id'] as String,
        timestamp: _decodeDateTime(data['timestamp']),
        type: data['type'] as String,
        description: data['description'] as String,
        metadata: _decodeJsonMap(data['metadata']),
        userId: data['user_id'] as String?,
      );
}

@DriftAccessor(tables: [FoodItems])
class FoodItemsDao extends DatabaseAccessor<AppDatabase>
    with _$FoodItemsDaoMixin {
  FoodItemsDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(FoodItem item) => db.foodItemToColumns(item);

  FoodItem fromMap(Map<String, dynamic> map) => db.mapFoodItem(map);
}

@DriftAccessor(tables: [Ingredients])
class IngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientsDaoMixin {
  IngredientsDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(
    Ingredient ingredient, {
    String? recipeId,
    String? mealEntryId,
  }) =>
      db.ingredientToColumns(
        ingredient,
        recipeId: recipeId,
        mealEntryId: mealEntryId,
      );

  Ingredient fromMap(Map<String, dynamic> map, FoodItem item) =>
      db.mapIngredient(map, item);
}

@DriftAccessor(tables: [MealEntries])
class MealEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$MealEntriesDaoMixin {
  MealEntriesDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(MealEntry entry) =>
      db.mealEntryToColumns(entry);

  MealEntry fromMap(
    Map<String, dynamic> map, {
    List<Ingredient> ingredients = const <Ingredient>[],
  }) =>
      db.mapMealEntry(map, ingredients: ingredients);
}

@DriftAccessor(tables: [Recipes])
class RecipesDao extends DatabaseAccessor<AppDatabase>
    with _$RecipesDaoMixin {
  RecipesDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(Recipe recipe) => db.recipeToColumns(recipe);

  Recipe fromMap(
    Map<String, dynamic> map, {
    List<Ingredient> ingredients = const <Ingredient>[],
  }) =>
      db.mapRecipe(map, ingredients: ingredients);
}

@DriftAccessor(tables: [ShoppingPlans])
class ShoppingPlansDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingPlansDaoMixin {
  ShoppingPlansDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(ShoppingPlan plan) =>
      db.shoppingPlanToColumns(plan);

  ShoppingPlan fromMap(
    Map<String, dynamic> map, {
    List<PantryItem> items = const <PantryItem>[],
  }) =>
      db.mapShoppingPlan(map, items: items);
}

@DriftAccessor(tables: [PantryItems])
class PantryItemsDao extends DatabaseAccessor<AppDatabase>
    with _$PantryItemsDaoMixin {
  PantryItemsDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(
    PantryItem item, {
    String? shoppingPlanId,
  }) =>
      db.pantryItemToColumns(item, shoppingPlanId: shoppingPlanId);

  PantryItem fromMap(Map<String, dynamic> map) => db.mapPantryItem(map);
}

@DriftAccessor(tables: [UserProfiles])
class UserProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfilesDaoMixin {
  UserProfilesDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(UserProfile profile) =>
      db.userProfileToColumns(profile);

  UserProfile fromMap(Map<String, dynamic> map) => db.mapUserProfile(map);
}

@DriftAccessor(tables: [EventLogs])
class EventLogsDao extends DatabaseAccessor<AppDatabase>
    with _$EventLogsDaoMixin {
  EventLogsDao(AppDatabase db) : super(db);

  Map<String, dynamic> toColumns(EventLog log) => db.eventLogToColumns(log);

  EventLog fromMap(Map<String, dynamic> map) => db.mapEventLog(map);
}
