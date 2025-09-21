import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meals_feature/meals_feature.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipes_feature/recipes_feature.dart';

class _MockMealsRepository extends Mock implements MealsRepository {}

class _FakeMealEntry extends Fake implements MealEntry {}

void main() {
  late MealsRepository mealsRepository;
  late Recipe recipe;

  setUpAll(() {
    registerFallbackValue(_FakeMealEntry());
  });

  setUp(() {
    mealsRepository = _MockMealsRepository();
    recipe = _buildRecipe();
  });

  testWidgets('scales ingredients and nutrients when servings change',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeDetailScreen(
          recipe: recipe,
          mealsRepository: mealsRepository,
          mealType: MealType.lunch,
          consumedAt: DateTime(2024, 1, 10, 12),
        ),
      ),
    );

    await tester.pump();

    expect(find.textContaining('100 g'), findsOneWidget);
    expect(find.textContaining('50 g'), findsOneWidget);

    final caloriesFinder = find.byKey(const Key('nutrient_calories_value'));
    final proteinFinder = find.byKey(const Key('nutrient_protein_value'));
    final carbsFinder = find.byKey(const Key('nutrient_carbs_value'));
    final fatFinder = find.byKey(const Key('nutrient_fat_value'));

    expect(
      tester.widget<Text>(caloriesFinder).data,
      '260 kcal',
    );
    expect(
      tester.widget<Text>(proteinFinder).data,
      '13 g',
    );
    expect(
      tester.widget<Text>(carbsFinder).data,
      '25 g',
    );
    expect(
      tester.widget<Text>(fatFinder).data,
      '7 g',
    );

    final incrementButton = find.descendant(
      of: find.byType(QuantityStepper),
      matching: find.byIcon(Icons.add),
    );

    await tester.tap(incrementButton);
    await tester.pump();

    expect(find.textContaining('125 g'), findsOneWidget);
    expect(find.textContaining('62.5 g'), findsOneWidget);

    expect(
      tester.widget<Text>(caloriesFinder).data,
      '325 kcal',
    );
    expect(
      tester.widget<Text>(proteinFinder).data,
      '16.3 g',
    );
    expect(
      tester.widget<Text>(carbsFinder).data,
      '31.3 g',
    );
    expect(
      tester.widget<Text>(fatFinder).data,
      '8.8 g',
    );
  });

  testWidgets('adds the scaled recipe as a meal entry', (tester) async {
    when(() => mealsRepository.upsertMeal(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeDetailScreen(
          recipe: recipe,
          mealsRepository: mealsRepository,
          mealType: MealType.dinner,
          consumedAt: DateTime(2024, 1, 10, 20),
        ),
      ),
    );

    await tester.pump();

    final incrementButton = find.descendant(
      of: find.byType(QuantityStepper),
      matching: find.byIcon(Icons.add),
    );

    await tester.tap(incrementButton);
    await tester.pump();

    await tester.tap(find.text('Aggiungi al pasto'));
    await tester.pump();

    final captured =
        verify(() => mealsRepository.upsertMeal(captureAny())).captured.single
            as MealEntry;

    expect(captured.recipeId, recipe.id);
    expect(captured.mealType, MealType.dinner);
    expect(captured.servings, 2.5);
    expect(captured.ingredients, hasLength(2));
    expect(captured.ingredients.first.quantity, closeTo(125, 0.001));
    expect(captured.ingredients.last.quantity, closeTo(62.5, 0.001));
  });
}

Recipe _buildRecipe() {
  final firstItem = FoodItem(
    id: 'food-1',
    name: 'Ingrediente principale',
    nutrients: const Nutrients(
      calories: 200,
      protein: 10,
      fat: 5,
      carbohydrates: 20,
      fiber: 4,
      sugar: 6,
      sodium: 100,
    ),
    servingSize: 100,
    servingUnit: UnitType.gram,
  );

  final secondItem = FoodItem(
    id: 'food-2',
    name: 'Ingrediente secondario',
    nutrients: const Nutrients(
      calories: 120,
      protein: 6,
      fat: 4,
      carbohydrates: 10,
      fiber: 2,
      sugar: 3,
      sodium: 80,
    ),
    servingSize: 100,
    servingUnit: UnitType.gram,
  );

  return Recipe(
    id: 'recipe-1',
    title: 'Ricetta di prova',
    description: 'Una ricetta utilizzata per i test.',
    nutrients: const Nutrients(
      calories: 0,
      protein: 0,
      fat: 0,
      carbohydrates: 0,
      fiber: 0,
      sugar: 0,
      sodium: 0,
    ),
    servingSize: 2,
    servingUnit: UnitType.serving,
    ingredients: [
      Ingredient(
        id: 'ing-1',
        item: firstItem,
        quantity: 100,
        unit: UnitType.gram,
        preparation: 'grigliato',
      ),
      Ingredient(
        id: 'ing-2',
        item: secondItem,
        quantity: 50,
        unit: UnitType.gram,
        preparation: 'tritato',
      ),
    ],
    instructions: const ['Step 1'],
    tags: const ['test'],
    prepTimeMinutes: 10,
    cookTimeMinutes: 5,
  );
}
