import 'dart:math';

import 'package:core_kit/core_kit.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:recommender_kit/recommender_kit.dart';

import 'weekly_plan.dart';

/// Generates weekly meal plans leveraging the recommendation engine.
class PlannerService {
  PlannerService({
    required Recommender recommender,
    DateTime Function()? now,
  })  : _recommender = recommender,
        _now = now ?? DateTime.now,
        _random = Random();

  final Recommender _recommender;
  final DateTime Function() _now;
  final Random _random;

  static const List<MealType> _mealOrder = <MealType>[
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
  ];

  static const Map<MealType, int> _mealHours = <MealType, int>{
    MealType.breakfast: 8,
    MealType.lunch: 13,
    MealType.dinner: 19,
  };

  /// Builds a [WeeklyMealPlan] starting on [startDate] (defaults to today).
  ///
  /// The generated plan always covers seven consecutive days with three meals
  /// per day (breakfast, lunch, dinner). Suggestions are obtained from the
  /// injected [Recommender] while ensuring a reasonable rotation of recipes.
  Future<WeeklyMealPlan> generateWeeklyPlan({
    required UserProfile profile,
    required List<Recipe> recipes,
    DateTime? startDate,
    List<MealEntry> recentMeals = const <MealEntry>[],
  }) async {
    if (recipes.isEmpty) {
      throw ArgumentError('At least one recipe is required to build a plan.');
    }

    final normalizedStart = _normalize(startDate ?? _now());
    final history = List<MealEntry>.from(recentMeals);
    final plannedDays = <PlannedDay>[];

    for (var offset = 0; offset < 7; offset += 1) {
      final dayDate = normalizedStart.add(Duration(days: offset));
      final meals = <MealEntry>[];
      var consumed = const Nutrients();

      for (final mealType in _mealOrder) {
        final recipe = await _selectRecipe(
          profile: profile,
          mealType: mealType,
          candidates: recipes,
          history: history,
          consumed: consumed,
          day: dayDate,
        );
        final entry = _buildMealEntry(dayDate, mealType, recipe);
        meals.add(entry);
        history.add(entry);
        consumed = _add(consumed, _nutrientsForMeal(entry));
      }

      plannedDays.add(PlannedDay(date: dayDate, meals: meals));
    }

    return WeeklyMealPlan(startDate: normalizedStart, days: plannedDays);
  }

  Future<Recipe> _selectRecipe({
    required UserProfile profile,
    required MealType mealType,
    required List<Recipe> candidates,
    required List<MealEntry> history,
    required Nutrients consumed,
    required DateTime day,
  }) async {
    final context = SuggestionContext(
      profile: profile,
      mealType: mealType,
      candidates: candidates,
      targetMacros: _targetMacros(profile),
      consumedMacros: consumed,
      recentMeals: _recentMeals(history, reference: day),
      referenceTime: day,
      recentMealWindow: const Duration(days: 7),
    );

    final suggestions = await _recommender.recommend(context);
    if (suggestions.isEmpty) {
      return candidates[_randomIndex(candidates.length)];
    }

    for (final suggestion in suggestions) {
      if (!_isRecipeRecentlyUsed(suggestion.recipe.id, history)) {
        return suggestion.recipe;
      }
    }

    return suggestions.first.recipe;
  }

  MealEntry _buildMealEntry(DateTime day, MealType type, Recipe recipe) {
    final hour = _mealHours[type] ?? 12;
    final consumedAt = DateTime(day.year, day.month, day.day, hour);
    final ingredients = recipe.ingredients
        .map((ingredient) => Ingredient.create(
              item: ingredient.item,
              quantity: ingredient.quantity,
              unit: ingredient.unit,
              preparation: ingredient.preparation,
            ))
        .toList(growable: false);

    return MealEntry.create(
      mealType: type,
      consumedAt: consumedAt,
      ingredients: ingredients,
      recipeId: recipe.id,
      servings: 1,
    );
  }

  Nutrients _targetMacros(UserProfile profile) {
    final mealsPerDay = max(_mealOrder.length, 1);
    final caloriesPerMeal = profile.dailyCalorieTarget / mealsPerDay;
    return Nutrients(calories: caloriesPerMeal);
  }

  Nutrients _nutrientsForMeal(MealEntry entry) {
    var total = const Nutrients();
    for (final ingredient in entry.ingredients) {
      final nutrients = computeNutrients(
        ingredient.item,
        ingredient.quantity,
        ingredient.unit,
      );
      total = _add(total, nutrients);
    }
    return total;
  }

  Nutrients _add(Nutrients base, Nutrients addition) {
    return Nutrients(
      calories: base.calories + addition.calories,
      protein: base.protein + addition.protein,
      fat: base.fat + addition.fat,
      carbohydrates: base.carbohydrates + addition.carbohydrates,
      fiber: base.fiber + addition.fiber,
      sugar: base.sugar + addition.sugar,
      sodium: base.sodium + addition.sodium,
    );
  }

  List<MealEntry> _recentMeals(
    List<MealEntry> history, {
    required DateTime reference,
  }) {
    final windowStart = reference.subtract(const Duration(days: 7));
    return history
        .where((entry) => entry.consumedAt.isAfter(windowStart))
        .toList(growable: false);
  }

  bool _isRecipeRecentlyUsed(String recipeId, List<MealEntry> history) {
    if (recipeId.isEmpty) {
      return false;
    }
    for (var i = history.length - 1; i >= 0 && history.length - i <= 9; i -= 1) {
      if (history[i].recipeId == recipeId) {
        return true;
      }
    }
    return false;
  }

  DateTime _normalize(DateTime value) => DateTime(value.year, value.month, value.day);

  int _randomIndex(int length) => _random.nextInt(max(length, 1));
}
