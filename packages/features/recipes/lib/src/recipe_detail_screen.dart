import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:meals_feature/meals_feature.dart';
import 'package:nutrition_kit/nutrition_kit.dart';

/// Displays the details of a [Recipe] allowing the user to scale servings
/// before logging it as a meal entry.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.mealsRepository,
    required this.mealType,
    required this.consumedAt,
  });

  /// Recipe displayed in the screen.
  final Recipe recipe;

  /// Repository used to persist the generated [MealEntry].
  final MealsRepository mealsRepository;

  /// Meal slot where the recipe should be logged.
  final MealType mealType;

  /// Timestamp associated with the logged meal.
  final DateTime consumedAt;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late final double _baseServings;
  late double _servings;
  late List<Ingredient> _scaledIngredients;
  late Nutrients _nutrients;

  @override
  void initState() {
    super.initState();
    _baseServings = widget.recipe.servingSize <= 0
        ? 1
        : widget.recipe.servingSize;
    _servings = _baseServings;
    _recalculate();
  }

  void _recalculate() {
    final factor = _baseServings == 0 ? 0 : _servings / _baseServings;
    _scaledIngredients = widget.recipe.ingredients
        .map(
          (ingredient) => ingredient.copyWith(
            quantity: ingredient.quantity * factor,
          ),
        )
        .toList(growable: false);

    _nutrients = _calculateNutrients(_scaledIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = widget.recipe.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          QuantityStepper(
            value: _servings,
            onChanged: (value) {
              setState(() {
                _servings = value;
                _recalculate();
              });
            },
            label: 'Porzioni',
            unitLabel: 'porz.',
            step: 0.5,
            min: 0.5,
            precision: 1,
          ),
          const SizedBox(height: 24),
          _NutrientSummary(nutrients: _nutrients),
          const SizedBox(height: 24),
          Text(
            'Ingredienti',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (_scaledIngredients.isEmpty)
            Text(
              'Nessun ingrediente disponibile per questa ricetta.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ..._scaledIngredients.map(_IngredientTile.new),
          if (widget.recipe.instructions.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Istruzioni',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...List<Widget>.generate(
              widget.recipe.instructions.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${index + 1}. ', style: theme.textTheme.titleMedium),
                    Expanded(
                      child: Text(
                        widget.recipe.instructions[index],
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Aggiungi al pasto',
            icon: const Icon(Icons.restaurant),
            expanded: true,
            onPressed: _scaledIngredients.isEmpty ? null : _addToMeal,
          ),
        ],
      ),
    );
  }

  Nutrients _calculateNutrients(List<Ingredient> ingredients) {
    var total = const Nutrients();
    for (final ingredient in ingredients) {
      final nutrients = computeNutrients(
        ingredient.item,
        ingredient.quantity,
        ingredient.unit,
      );
      total = Nutrients(
        calories: total.calories + nutrients.calories,
        protein: total.protein + nutrients.protein,
        fat: total.fat + nutrients.fat,
        carbohydrates: total.carbohydrates + nutrients.carbohydrates,
        fiber: total.fiber + nutrients.fiber,
        sugar: total.sugar + nutrients.sugar,
        sodium: total.sodium + nutrients.sodium,
      );
    }
    return total;
  }

  Future<void> _addToMeal() async {
    final entry = MealEntry.create(
      mealType: widget.mealType,
      consumedAt: widget.consumedAt,
      ingredients: _scaledIngredients,
      recipeId: widget.recipe.id,
      servings: _servings,
    );
    await widget.mealsRepository.upsertMeal(entry);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ricetta aggiunta al diario.'),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile(this.ingredient);

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _formatUnit(ingredient.unit);
    final quantity = _formatQuantity(ingredient.quantity);
    final details = <String>[
      unit == null ? quantity : '$quantity $unit',
    ];
    final preparation = ingredient.preparation;
    if (preparation != null && preparation.isNotEmpty) {
      details.add(preparation);
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          ingredient.item.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          details.where((segment) => segment.isNotEmpty).join(' • '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String? _formatUnit(UnitType unit) {
    switch (unit) {
      case UnitType.gram:
        return 'g';
      case UnitType.milliliter:
        return 'ml';
      case UnitType.ounce:
        return 'oz';
      case UnitType.pound:
        return 'lb';
      case UnitType.piece:
        return 'pz';
      case UnitType.cup:
        return 'cup';
      case UnitType.tablespoon:
        return 'cucchiaio';
      case UnitType.teaspoon:
        return 'cucchiaino';
      case UnitType.serving:
        return 'porz.';
    }
  }

  String _formatQuantity(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _NutrientSummary extends StatelessWidget {
  const _NutrientSummary({required this.nutrients});

  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_NutrientData>[
      _NutrientData(
        label: 'Calorie',
        value: nutrients.calories,
        unit: 'kcal',
        valueKey: const Key('nutrient_calories_value'),
      ),
      _NutrientData(
        label: 'Proteine',
        value: nutrients.protein,
        unit: 'g',
        valueKey: const Key('nutrient_protein_value'),
      ),
      _NutrientData(
        label: 'Carboidrati',
        value: nutrients.carbohydrates,
        unit: 'g',
        valueKey: const Key('nutrient_carbs_value'),
      ),
      _NutrientData(
        label: 'Grassi',
        value: nutrients.fat,
        unit: 'g',
        valueKey: const Key('nutrient_fat_value'),
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valori nutrizionali',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _NutrientRow(item: item)),
          ],
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.item});

  final _NutrientData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            '${item.formattedValue} ${item.unit}',
            key: item.valueKey,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _NutrientData {
  _NutrientData({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueKey,
  });

  final String label;
  final double value;
  final String unit;
  final Key valueKey;

  String get formattedValue {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
