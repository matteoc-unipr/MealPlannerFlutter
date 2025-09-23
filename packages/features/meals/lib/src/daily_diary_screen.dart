import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'meals_repository.dart';

/// Displays the logged meals and macro nutrients for a single day.
class DailyDiaryScreen extends StatefulWidget {
  const DailyDiaryScreen({
    super.key,
    required this.repository,
    required DateTime date,
  }) : date = DateTime(date.year, date.month, date.day);

  /// Repository providing the diary data.
  final MealsRepository repository;

  /// Day rendered by this screen. The time component is ignored.
  final DateTime date;

  @override
  State<DailyDiaryScreen> createState() => _DailyDiaryScreenState();
}

class _DailyDiaryScreenState extends State<DailyDiaryScreen> {
  late final Stream<DailyDiary> _diaryStream;

  @override
  void initState() {
    super.initState();
    _diaryStream = widget.repository.watchDiary(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.date);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyDiaryTitle(formattedDate)),
      ),
      body: StreamBuilder<DailyDiary>(
        stream: _diaryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final diary = snapshot.data!;
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.dailyDiaryMacroSummaryTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              _MacroSummary(summary: diary.macroSummary),
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  l10n.dailyDiaryMealsSectionTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              if (diary.meals.isEmpty)
                Text(
                  l10n.dailyDiaryNoMealsMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...diary.meals.map((meal) => _MealTile(meal: meal)),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _MacroSummary extends StatelessWidget {
  const _MacroSummary({required this.summary});

  final DailyMacroSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final macros = <_MacroData>[
      _MacroData(
        label: l10n.macroCaloriesLabel,
        value: summary.consumed.calories,
        goal: summary.goal.calories,
        unit: 'kcal',
      ),
      _MacroData(
        label: l10n.macroProteinLabel,
        value: summary.consumed.protein,
        goal: summary.goal.protein,
        unit: 'g',
      ),
      _MacroData(
        label: l10n.macroCarbsLabel,
        value: summary.consumed.carbohydrates,
        goal: summary.goal.carbohydrates,
        unit: 'g',
      ),
      _MacroData(
        label: l10n.macroFatLabel,
        value: summary.consumed.fat,
        goal: summary.goal.fat,
        unit: 'g',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final itemWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: macros
              .map(
                (macro) => SizedBox(
                  width: itemWidth,
                  child: _MacroCard(macro: macro),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.macro});

  final _MacroData macro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final goalText = l10n.dailyDiaryMacroGoal(macro.formattedGoal);
    return Semantics(
      label: macro.label,
      value: macro.formattedValue,
      hint: goalText,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NutrientRing(
                value: macro.value,
                goal: macro.goal,
                size: 120,
                strokeWidth: 10,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${macro.percent}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      macro.label,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                macro.formattedValue,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                goalText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroData {
  _MacroData({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
  });

  final String label;
  final double value;
  final double goal;
  final String unit;

  int get percent {
    if (goal <= 0) {
      return 0;
    }
    final ratio = (value / goal).clamp(0.0, 1.0);
    return (ratio * 100).round();
  }

  String get formattedValue => '${_formatNumber(value)} $unit';

  String get formattedGoal => '${_formatNumber(goal)} $unit';

  String _formatNumber(double value) {
    if (value == 0) {
      return '0';
    }
    if (value >= 100) {
      return value.toStringAsFixed(0).replaceAll('.', ',');
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final time = TimeOfDay.fromDateTime(meal.consumedAt);
    final timeLabel = time.format(context);
    final ingredients = meal.ingredients;
    final subtitle = ingredients.isEmpty
        ? l10n.mealTileNoIngredients
        : ingredients.map((ingredient) => ingredient.item.name).join(', ');
    final mealTypeLabel = _mealTypeLabel(meal.mealType, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          l10n.mealTypeWithTime(mealTypeLabel, timeLabel),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  String _mealTypeLabel(MealType type, AppLocalizations l10n) {
    switch (type) {
      case MealType.breakfast:
        return l10n.mealTypeBreakfast;
      case MealType.lunch:
        return l10n.mealTypeLunch;
      case MealType.dinner:
        return l10n.mealTypeDinner;
      case MealType.snack:
        return l10n.mealTypeSnack;
    }
  }
}
