import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:shopping_feature/shopping_feature.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_manager.dart';
import 'planner_service.dart';
import 'weekly_plan.dart';

typedef RecipesProvider = Future<List<Recipe>> Function();

/// Coordinates the daily background job responsible for keeping the planner
/// and shopping list in sync.
class BackgroundWorker {
  BackgroundWorker({
    required Workmanager workmanager,
    required PlannerService plannerService,
    required ShoppingService shoppingService,
    required UserProfileDao userProfileDao,
    required MealEntryDao mealEntryDao,
    required ShoppingPlanDao shoppingPlanDao,
    required NotificationManager notificationManager,
    required RecipesProvider recipesProvider,
    DateTime Function()? now,
  })  : _workmanager = workmanager,
        _plannerService = plannerService,
        _shoppingService = shoppingService,
        _userProfileDao = userProfileDao,
        _mealEntryDao = mealEntryDao,
        _shoppingPlanDao = shoppingPlanDao,
        _notificationManager = notificationManager,
        _recipesProvider = recipesProvider,
        _now = now ?? DateTime.now;

  final Workmanager _workmanager;
  final PlannerService _plannerService;
  final ShoppingService _shoppingService;
  final UserProfileDao _userProfileDao;
  final MealEntryDao _mealEntryDao;
  final ShoppingPlanDao _shoppingPlanDao;
  final NotificationManager _notificationManager;
  final RecipesProvider _recipesProvider;
  final DateTime Function() _now;

  /// Identifier for the periodic background task.
  static const String taskName = 'daily_planner_refresh';

  /// Registers the periodic background task with the operating system.
  Future<void> registerDailyTask({bool replaceExisting = true}) {
    return _workmanager.registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 15),
      existingWorkPolicy:
          replaceExisting ? ExistingWorkPolicy.replace : ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  /// Executes the job logic and returns whether it completed successfully.
  Future<bool> handleWork(Map<String, dynamic>? inputData) async {
    try {
      await runOnce();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Regenerates the weekly plan, updates the database and schedules reminders.
  Future<void> runOnce() async {
    final profiles = await _userProfileDao.getProfiles();
    if (profiles.isEmpty) {
      return;
    }
    final profile = profiles.first;

    final recipes = await _recipesProvider();
    if (recipes.isEmpty) {
      return;
    }

    final executionTime = _now();
    final existingEntries = await _mealEntryDao.getMealEntries();
    final plan = await _plannerService.generateWeeklyPlan(
      profile: profile,
      recipes: recipes,
      startDate: executionTime,
      recentMeals: existingEntries,
    );

    await _replacePlannedMeals(plan, existingEntries);

    final summary = _shoppingService.buildSummary(
      plannedMeals: plan.meals,
      profile: profile,
      planStart: plan.startDate,
      reference: executionTime,
    );

    await _shoppingPlanDao.upsertPlan(summary.plan);
    await _notificationManager.scheduleShoppingReminder(
      summary.nextShoppingDate,
    );
  }

  Future<void> _replacePlannedMeals(
    WeeklyMealPlan plan,
    List<MealEntry> existingEntries,
  ) async {
    final rangeStart = plan.startDate;
    final rangeEndExclusive = plan.endDate.add(const Duration(days: 1));

    final toDelete = existingEntries.where((entry) {
      final consumedAt = entry.consumedAt;
      return !consumedAt.isBefore(rangeStart) &&
          consumedAt.isBefore(rangeEndExclusive);
    }).toList(growable: false);

    for (final entry in toDelete) {
      await _mealEntryDao.deleteMealEntry(entry.id);
    }

    for (final meal in plan.meals) {
      await _mealEntryDao.upsertMealEntry(meal);
    }
  }
}
