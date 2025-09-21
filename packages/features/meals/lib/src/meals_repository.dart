import 'dart:async';

import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:nutrition_kit/nutrition_kit.dart';

/// Aggregated information about the logged meals for a specific day.
class DailyDiary {
  const DailyDiary({
    required this.date,
    required this.meals,
    required this.macroSummary,
  });

  /// Date represented by this snapshot (time stripped).
  final DateTime date;

  /// Meals logged for the date ordered chronologically.
  final List<MealEntry> meals;

  /// Total macro nutrients consumed during the day.
  final DailyMacroSummary macroSummary;
}

/// Provides macro totals and goal information for a day.
class DailyMacroSummary {
  const DailyMacroSummary({
    required this.consumed,
    required this.goal,
  });

  /// Nutrients consumed for the day.
  final Nutrients consumed;

  /// Target nutrients used for progress visualisation.
  final Nutrients goal;
}

/// Repository that coordinates persistence of [MealEntry] records using Drift.
class MealsRepository {
  MealsRepository(
    this._mealEntryDao, {
    Nutrients? dailyMacroGoal,
  }) : _dailyGoal = dailyMacroGoal ??
            const Nutrients(
              calories: 2000,
              protein: 90,
              fat: 70,
              carbohydrates: 250,
            ) {
    // Load the initial cache asynchronously.
    unawaited(_refresh());
  }

  final MealEntryDao _mealEntryDao;
  final Nutrients _dailyGoal;

  final _entriesController = StreamController<List<MealEntry>>.broadcast();
  List<MealEntry> _cache = const <MealEntry>[];
  bool _disposed = false;

  /// Stream emitting diary snapshots for the given [day].
  Stream<DailyDiary> watchDiary(DateTime day) {
    final normalized = _normalize(day);
    return _entriesStream().map(
      (entries) => _buildDiarySnapshot(entries, normalized),
    );
  }

  /// Returns meals logged for [day] without subscribing to updates.
  Future<List<MealEntry>> loadMealsForDay(DateTime day) async {
    final normalized = _normalize(day);
    final entries = await _mealEntryDao.getMealEntries();
    return _filterEntriesForDay(entries, normalized);
  }

  /// Persists [entry] replacing any existing record with the same id.
  Future<void> upsertMeal(MealEntry entry) async {
    await _mealEntryDao.upsertMealEntry(entry);
    await _refresh();
  }

  /// Deletes the meal entry identified by [id].
  Future<void> deleteMeal(String id) async {
    await _mealEntryDao.deleteMealEntry(id);
    await _refresh();
  }

  /// Forces a refresh of the cached entries. Exposed for testability.
  @visibleForTesting
  Future<void> refresh() => _refresh();

  /// Releases resources held by the repository.
  Future<void> dispose() async {
    _disposed = true;
    await _entriesController.close();
  }

  Stream<List<MealEntry>> _entriesStream() {
    return Stream<List<MealEntry>>.multi((controller) {
      if (_disposed) {
        controller.close();
        return;
      }

      controller.add(_cache);
      final subscription = _entriesController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  Future<void> _refresh() async {
    final entries = await _mealEntryDao.getMealEntries();
    if (_disposed) {
      return;
    }
    _cache = List<MealEntry>.unmodifiable(entries);
    if (!_entriesController.isClosed) {
      _entriesController.add(_cache);
    }
  }

  DailyDiary _buildDiarySnapshot(List<MealEntry> entries, DateTime day) {
    final meals = _filterEntriesForDay(entries, day);
    meals.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    final macroSummary = DailyMacroSummary(
      consumed: _calculateNutrients(meals),
      goal: _dailyGoal,
    );
    return DailyDiary(
      date: day,
      meals: List<MealEntry>.unmodifiable(meals),
      macroSummary: macroSummary,
    );
  }

  List<MealEntry> _filterEntriesForDay(List<MealEntry> entries, DateTime day) {
    return entries
        .where((entry) => _isSameDay(entry.consumedAt, day))
        .toList(growable: true);
  }

  Nutrients _calculateNutrients(List<MealEntry> entries) {
    var total = const Nutrients();
    for (final entry in entries) {
      for (final ingredient in entry.ingredients) {
        final nutrients = computeNutrients(
          ingredient.item,
          ingredient.quantity,
          ingredient.unit,
        );
        total = _addNutrients(total, nutrients);
      }
    }
    return total;
  }

  Nutrients _addNutrients(Nutrients base, Nutrients addition) {
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

  DateTime _normalize(DateTime value) => DateTime(value.year, value.month, value.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
