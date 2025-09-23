import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meals_feature/meals_feature.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealsRepository extends Mock implements MealsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      MealEntry.create(
        mealType: MealType.dinner,
        consumedAt: DateTime.utc(2024, 1, 1, 19),
      ),
    );
  });

  testWidgets('adds the suggested recipe to the diary', (tester) async {
    final repository = _MockMealsRepository();
    when(() => repository.upsertMeal(any())).thenAnswer((_) async {});

    final foodItem = FoodItem.create(
      name: 'Quinoa',
      nutrients:
          const Nutrients(calories: 222, protein: 8, fat: 4, carbohydrates: 35),
      servingSize: 100,
      servingUnit: UnitType.gram,
    );

    final recipe = Recipe.create(
      title: 'Quinoa salad',
      description: 'Fresh and light.',
      nutrients: const Nutrients(
          calories: 420, protein: 16, fat: 12, carbohydrates: 60),
      servingSize: 1,
      servingUnit: UnitType.serving,
      ingredients: <Ingredient>[
        Ingredient.create(item: foodItem, quantity: 150, unit: UnitType.gram),
      ],
      instructions: const <String>['Mix ingredients', 'Serve chilled'],
      tags: const <String>['lunch'],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RecipeDetailScreen(
          recipe: recipe,
          mealsRepository: repository,
          mealType: MealType.lunch,
          consumedAt: DateTime.utc(2024, 5, 10, 12),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to meal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => repository.upsertMeal(any())).called(1);
    expect(find.text('Recipe added to diary.'), findsOneWidget);
  });
}
