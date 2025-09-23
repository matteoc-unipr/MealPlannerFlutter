import 'dart:math' as math;

import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrition_kit/nutrition_kit.dart';

/// Confirmation screen displayed after a barcode lookup resolves to a [FoodItem].
class ConfirmFoodScreen extends StatefulWidget {
  const ConfirmFoodScreen({
    super.key,
    required this.foodItem,
    required this.mealRepository,
    required this.mealType,
    required this.nutritionProvider,
  });

  final FoodItem foodItem;
  final MealRepository mealRepository;
  final MealType mealType;
  final CompositeNutritionProvider nutritionProvider;

  @override
  State<ConfirmFoodScreen> createState() => _ConfirmFoodScreenState();
}

class _ConfirmFoodScreenState extends State<ConfirmFoodScreen> {
  static const double _quantityStep = 0.5;

  late double _quantity;
  late UnitType _unit;
  bool _loadingNutrients = true;
  bool _saving = false;
  Nutrients? _nutrients;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _quantity = widget.foodItem.servingSize > 0
        ? widget.foodItem.servingSize
        : 1.0;
    _unit = widget.foodItem.servingUnit;
    _loadNutrients();
  }

  Future<void> _loadNutrients() async {
    try {
      final result = await widget.nutritionProvider.nutrientsFor(widget.foodItem);
      if (!mounted) {
        return;
      }
      setState(() {
        _nutrients = result ?? widget.foodItem.nutrients;
        _loadingNutrients = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nutrients = widget.foodItem.nutrients;
        _loadingNutrients = false;
        _errorMessage =
            AppLocalizations.of(context)!.confirmFoodNutritionUpdateError;
      });
    }
  }

  Future<void> _handleAdd() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await widget.mealRepository.addIngredient(
        mealType: widget.mealType,
        item: widget.foodItem,
        quantity: _quantity,
        unit: _unit,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.confirmFoodAddError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity = _roundToStep(_quantity + _quantityStep);
    });
  }

  void _decrementQuantity() {
    setState(() {
      _quantity = _roundToStep(math.max(0.1, _quantity - _quantityStep));
    });
  }

  double _roundToStep(double value) {
    final scaled = (value / _quantityStep).round();
    final result = scaled * _quantityStep;
    return result.clamp(0.1, 9999).toDouble();
  }

  Nutrients get _scaledNutrients {
    final base = _nutrients ?? widget.foodItem.nutrients;
    final serving = widget.foodItem.servingSize > 0
        ? widget.foodItem.servingSize
        : 1.0;
    final factor = _quantity / serving;
    return base.copyWith(
      calories: base.calories * factor,
      protein: base.protein * factor,
      fat: base.fat * factor,
      carbohydrates: base.carbohydrates * factor,
      fiber: base.fiber * factor,
      sugar: base.sugar * factor,
      sodium: base.sodium * factor,
    );
  }

  String get _portionDescription {
    final l10n = AppLocalizations.of(context)!;
    return '${_formatQuantity(_quantity)} ${_unitLabel(_unit, l10n).toLowerCase()}';
  }

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0).replaceAll('.', ',');
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _unitLabel(UnitType unit, AppLocalizations l10n) {
    switch (unit) {
      case UnitType.gram:
        return l10n.unitGram;
      case UnitType.milliliter:
        return l10n.unitMilliliter;
      case UnitType.ounce:
        return l10n.unitOunce;
      case UnitType.pound:
        return l10n.unitPound;
      case UnitType.piece:
        return l10n.unitPiece;
      case UnitType.cup:
        return l10n.unitCup;
      case UnitType.tablespoon:
        return l10n.unitTablespoon;
      case UnitType.teaspoon:
        return l10n.unitTeaspoon;
      case UnitType.serving:
        return l10n.unitServing;
    }
  }

  Widget _buildQuantityControls(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity <= 0.5 ? null : _decrementQuantity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _formatQuantity(_quantity),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<UnitType>(
            value: _unit,
            decoration: InputDecoration(
              labelText: l10n.confirmFoodUnitLabel,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _unit = value;
                });
              }
            },
            items: UnitType.values
                .map(
                  (unit) => DropdownMenuItem<UnitType>(
                    value: unit,
                    child: Text(_unitLabel(unit, l10n)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientSummary(ThemeData theme) {
    if (_loadingNutrients) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final nutrients = _scaledNutrients;
    final l10n = AppLocalizations.of(context)!;
    final values = <_NutrientValue>[
      _NutrientValue(l10n.confirmFoodNutrientsCalories, nutrients.calories, 'kcal'),
      _NutrientValue(l10n.confirmFoodNutrientsProtein, nutrients.protein, 'g'),
      _NutrientValue(l10n.confirmFoodNutrientsFat, nutrients.fat, 'g'),
      _NutrientValue(l10n.confirmFoodNutrientsCarbs, nutrients.carbohydrates, 'g'),
      _NutrientValue(l10n.confirmFoodNutrientsFiber, nutrients.fiber, 'g'),
      _NutrientValue(l10n.confirmFoodNutrientsSugar, nutrients.sugar, 'g'),
      _NutrientValue(l10n.confirmFoodNutrientsSodium, nutrients.sodium, 'mg'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.confirmFoodNutritionTitle(_portionDescription),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...values.map(
          (value) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Semantics(
              label: value.label,
              value: value.formatted,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value.label, style: theme.textTheme.bodyLarge),
                  Text(
                    value.formatted,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.confirmFoodTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.foodItem.name,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (widget.foodItem.brand != null && widget.foodItem.brand!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.foodItem.brand!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (widget.foodItem.description != null &&
                widget.foodItem.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.foodItem.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),
            _buildQuantityControls(theme),
            const SizedBox(height: 24),
            _buildNutrientSummary(theme),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _handleAdd,
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonAddToMeal),
            ),
          ),
        ),
      ),
    );
  }
}

class _NutrientValue {
  _NutrientValue(this.label, this.value, this.suffix);

  final String label;
  final double value;
  final String suffix;

  String get formatted {
    final formattedValue =
        value.toStringAsFixed(value >= 100 ? 0 : 1).replaceAll('.', ',');
    return '$formattedValue $suffix';
  }
}

/// Abstraction over the persistence layer for meal entries.
abstract class MealRepository {
  Future<void> addIngredient({
    required MealType mealType,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
  });
}

/// Default implementation backed by the [MealEntryDao] from `data_kit`.
class DataKitMealRepository implements MealRepository {
  DataKitMealRepository(this._mealEntryDao);

  final MealEntryDao _mealEntryDao;

  @override
  Future<void> addIngredient({
    required MealType mealType,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
  }) {
    final ingredient = Ingredient.create(
      item: item,
      quantity: quantity,
      unit: unit,
    );

    final entry = MealEntry.create(
      mealType: mealType,
      consumedAt: DateTime.now(),
      ingredients: <Ingredient>[ingredient],
    );

    return _mealEntryDao.upsertMealEntry(entry);
  }
}
