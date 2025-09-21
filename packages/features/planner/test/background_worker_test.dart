import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_feature/shopping_feature.dart';
import 'package:workmanager/workmanager.dart';

import 'package:planner_feature/planner_feature.dart';

class _MockWorkmanager extends Mock implements Workmanager {}

class _MockPlannerService extends Mock implements PlannerService {}

class _MockShoppingService extends Mock implements ShoppingService {}

class _MockUserProfileDao extends Mock implements UserProfileDao {}

class _MockMealEntryDao extends Mock implements MealEntryDao {}

class _MockShoppingPlanDao extends Mock implements ShoppingPlanDao {}

class _MockNotificationManager extends Mock implements NotificationManager {}

void main() {
  group('BackgroundWorker', () {
    late _MockWorkmanager workmanager;
    late _MockPlannerService plannerService;
    late _MockShoppingService shoppingService;
    late _MockUserProfileDao userProfileDao;
    late _MockMealEntryDao mealEntryDao;
    late _MockShoppingPlanDao shoppingPlanDao;
    late _MockNotificationManager notificationManager;
    late DateTime now;

    setUp(() {
      workmanager = _MockWorkmanager();
      plannerService = _MockPlannerService();
      shoppingService = _MockShoppingService();
      userProfileDao = _MockUserProfileDao();
      mealEntryDao = _MockMealEntryDao();
      shoppingPlanDao = _MockShoppingPlanDao();
      notificationManager = _MockNotificationManager();
      now = DateTime.utc(2024, 1, 1);
    });

    test('regenerates the plan and schedules notifications', () async {
      final profile = UserProfile(
        id: 'user-1',
        name: 'Mario',
        preferredDiet: DietModel.omnivore,
        shoppingDay: Weekday.thursday,
        dailyCalorieTarget: 2100,
        heightCm: 178,
        weightKg: 74,
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now.subtract(const Duration(days: 1)),
        allergies: const <String>[],
        dislikedIngredients: const <String>[],
      );

      final foodItem = FoodItem(
        id: 'food-1',
        name: 'Oats',
        nutrients: const Nutrients(calories: 100),
        servingSize: 40,
        servingUnit: UnitType.gram,
      );
      final ingredient = Ingredient(
        id: 'ing-1',
        item: foodItem,
        quantity: 80,
        unit: UnitType.gram,
      );
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Porridge',
        description: 'Colazione sana.',
        nutrients: const Nutrients(calories: 320),
        servingSize: 1,
        servingUnit: UnitType.serving,
        ingredients: <Ingredient>[ingredient],
      );
      final recipes = <Recipe>[recipe];

      final existingMeal = MealEntry(
        id: 'meal-existing',
        mealType: MealType.breakfast,
        consumedAt: now.add(const Duration(hours: 8)),
        ingredients: const <Ingredient>[],
      );
      final existingMeals = <MealEntry>[existingMeal];

      final plannedMeal = MealEntry(
        id: 'meal-planned',
        mealType: MealType.breakfast,
        consumedAt: now.add(const Duration(hours: 8)),
        ingredients: <Ingredient>[ingredient],
        recipeId: recipe.id,
        servings: 1,
      );
      final plan = WeeklyMealPlan(
        startDate: now,
        days: <PlannedDay>[
          PlannedDay(date: now, meals: <MealEntry>[plannedMeal]),
        ],
      );
      final plannedMeals = plan.meals;

      final shoppingPlan = ShoppingPlan(
        id: 'plan-${now.toIso8601String()}',
        weekStart: Weekday.monday,
        status: PlanStatus.pending,
        createdAt: now,
        updatedAt: now,
        items: const <PantryItem>[],
      );
      final summary = ShoppingSummary(
        plan: shoppingPlan,
        nextShoppingDate: now.add(const Duration(days: 3)),
      );

      when(() => userProfileDao.getProfiles()).thenAnswer((_) async => <UserProfile>[profile]);
      when(() => mealEntryDao.getMealEntries())
          .thenAnswer((_) async => existingMeals);
      when(() => plannerService.generateWeeklyPlan(
            profile: profile,
            recipes: recipes,
            startDate: now,
            recentMeals: existingMeals,
          )).thenAnswer((_) async => plan);
      when(() => shoppingService.buildSummary(
            plannedMeals: plannedMeals,
            profile: profile,
            planStart: plan.startDate,
            reference: now,
          )).thenReturn(summary);
      when(() => shoppingPlanDao.upsertPlan(summary.plan)).thenAnswer((_) async {});
      when(() => mealEntryDao.deleteMealEntry(existingMeal.id))
          .thenAnswer((_) async => 1);
      when(() => mealEntryDao.upsertMealEntry(plannedMeal)).thenAnswer((_) async {});
      when(() => notificationManager.scheduleShoppingReminder(summary.nextShoppingDate))
          .thenAnswer((_) async {});

      final worker = BackgroundWorker(
        workmanager: workmanager,
        plannerService: plannerService,
        shoppingService: shoppingService,
        userProfileDao: userProfileDao,
        mealEntryDao: mealEntryDao,
        shoppingPlanDao: shoppingPlanDao,
        notificationManager: notificationManager,
        recipesProvider: () async => recipes,
        now: () => now,
      );

      await worker.runOnce();

      verify(() => plannerService.generateWeeklyPlan(
            profile: profile,
            recipes: recipes,
            startDate: now,
            recentMeals: existingMeals,
          )).called(1);
      verify(() => mealEntryDao.deleteMealEntry(existingMeal.id)).called(1);
      verify(() => mealEntryDao.upsertMealEntry(plannedMeal)).called(1);
      verify(() => shoppingPlanDao.upsertPlan(summary.plan)).called(1);
      verify(() => notificationManager.scheduleShoppingReminder(summary.nextShoppingDate))
          .called(1);
    });
  });
}
