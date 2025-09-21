import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:data_kit/data_kit.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late AppDatabase database;
  late FoodItemDao foodItemDao;
  late MealEntryDao mealEntryDao;
  late UserProfileDao userProfileDao;
  late ShoppingPlanDao shoppingPlanDao;
  late List<FoodItem> seedFoodItems;

  setUp(() async {
    database = await initDatabase(
      executor: NativeDatabase.memory(),
      reset: true,
    );
    foodItemDao = FoodItemDao(database);
    mealEntryDao = MealEntryDao(database);
    userProfileDao = UserProfileDao(database);
    shoppingPlanDao = ShoppingPlanDao(database);

    final seedPath = p.normalize(
      p.join('..', 'core_kit', 'seed', 'seed_data.json'),
    );
    final seedContent = await File(seedPath).readAsString();
    final Map<String, dynamic> seedJson =
        jsonDecode(seedContent) as Map<String, dynamic>;

    seedFoodItems = (seedJson['foodItems'] as List<dynamic>)
        .map((dynamic entry) =>
            FoodItem.fromJson(entry as Map<String, dynamic>))
        .toList();

    await foodItemDao.insertAll(seedFoodItems);
  });

  tearDown(() async {
    await closeDatabase();
  });

  test('performs CRUD operations across DAOs', () async {
    final storedFoods = await foodItemDao.getAllFoodItems();
    expect(storedFoods.length, seedFoodItems.length);
    expect(storedFoods.first.name, seedFoodItems.first.name);

    final profile = UserProfile.create(
      name: 'Test User',
      preferredDiet: DietModel.omnivore,
      shoppingDay: Weekday.saturday,
      dailyCalorieTarget: 2200,
      heightCm: 180,
      weightKg: 75,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
      allergies: const <String>['peanut'],
      dislikedIngredients: const <String>['celery'],
    );
    await userProfileDao.upsertProfile(profile);

    final fetchedProfile = await userProfileDao.getProfile(profile.id);
    expect(fetchedProfile, isNotNull);
    expect(fetchedProfile!.name, 'Test User');
    expect(fetchedProfile.allergies, contains('peanut'));

    final updatedProfile = UserProfile(
      id: profile.id,
      name: 'Updated User',
      preferredDiet: profile.preferredDiet,
      shoppingDay: profile.shoppingDay,
      dailyCalorieTarget: profile.dailyCalorieTarget,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      createdAt: profile.createdAt,
      updatedAt: DateTime.utc(2024, 1, 2),
      birthDate: profile.birthDate,
      allergies: <String>[...profile.allergies, 'pollen'],
      dislikedIngredients: profile.dislikedIngredients,
      photoUrl: profile.photoUrl,
    );
    await userProfileDao.upsertProfile(updatedProfile);

    final refetchedProfile = await userProfileDao.getProfile(profile.id);
    expect(refetchedProfile, isNotNull);
    expect(refetchedProfile!.name, 'Updated User');
    expect(refetchedProfile.allergies, contains('pollen'));

    final ingredient = Ingredient.create(
      item: seedFoodItems.first,
      quantity: 1.5,
      unit: UnitType.serving,
      preparation: 'grilled',
    );

    final meal = MealEntry.create(
      mealType: MealType.breakfast,
      consumedAt: DateTime.utc(2024, 1, 2, 8),
      ingredients: <Ingredient>[ingredient],
      servings: 1.0,
      notes: 'Morning meal',
    );
    await mealEntryDao.upsertMealEntry(meal);

    final fetchedMeal = await mealEntryDao.getMealEntry(meal.id);
    expect(fetchedMeal, isNotNull);
    expect(fetchedMeal!.ingredients, isNotEmpty);
    expect(fetchedMeal.ingredients.single.item.id, seedFoodItems.first.id);

    final deletedCount = await mealEntryDao.deleteMealEntry(meal.id);
    expect(deletedCount, 1);
    final removedMeal = await mealEntryDao.getMealEntry(meal.id);
    expect(removedMeal, isNull);

    final plan = ShoppingPlan.create(
      weekStart: Weekday.monday,
      status: PlanStatus.active,
      createdAt: DateTime.utc(2024, 1, 3),
      items: <PantryItem>[
        PantryItem.create(
          name: 'Bananas',
          quantity: 6,
          unit: UnitType.piece,
        ),
        PantryItem.create(
          name: 'Greek Yogurt',
          quantity: 2,
          unit: UnitType.serving,
          isStaple: true,
        ),
      ],
      notes: 'Weekly groceries',
    );
    await shoppingPlanDao.upsertPlan(plan);

    final fetchedPlan = await shoppingPlanDao.getPlan(plan.id);
    expect(fetchedPlan, isNotNull);
    expect(fetchedPlan!.items.length, 2);
    expect(fetchedPlan.items.first.name, 'Bananas');

    final exportSnapshot = await exportJson();
    expect(exportSnapshot['foodItems'], isA<List<dynamic>>());
    expect((exportSnapshot['foodItems'] as List<dynamic>).length,
        seedFoodItems.length);
    expect(exportSnapshot['mealEntries'], isEmpty);
    expect((exportSnapshot['userProfiles'] as List<dynamic>).length, 1);
    expect((exportSnapshot['shoppingPlans'] as List<dynamic>).length, 1);

    await eraseAll();
    final clearedFoods = await foodItemDao.getAllFoodItems();
    expect(clearedFoods, isEmpty);
  });
}
