import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meals_feature/meals_feature.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryDao extends Mock implements MealEntryDao {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      MealEntry.create(
        mealType: MealType.breakfast,
        consumedAt: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  testWidgets('shows macro summary and meals for the selected day',
      (tester) async {
    final dao = _MockMealEntryDao();
    final date = DateTime(2024, 5, 10);

    final food = FoodItem.create(
      name: 'Pasta integrale',
      nutrients: const Nutrients(
        calories: 200,
        protein: 10,
        fat: 5,
        carbohydrates: 30,
      ),
      servingSize: 100,
      servingUnit: UnitType.gram,
    );

    final ingredient = Ingredient.create(
      item: food,
      quantity: 150,
      unit: UnitType.gram,
    );

    final meal = MealEntry.create(
      mealType: MealType.lunch,
      consumedAt: DateTime(2024, 5, 10, 13),
      ingredients: <Ingredient>[ingredient],
    );

    when(() => dao.getMealEntries()).thenAnswer((_) async => <MealEntry>[meal]);
    when(() => dao.upsertMealEntry(any())).thenAnswer((_) async {});
    when(() => dao.deleteMealEntry(any())).thenAnswer((_) async => 1);

    final repository = MealsRepository(
      dao,
      dailyMacroGoal: const Nutrients(
        calories: 600,
        protein: 40,
        fat: 20,
        carbohydrates: 90,
      ),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DailyDiaryScreen(repository: repository, date: date),
      ),
    );

    // Allow asynchronous loading from the repository.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Riepilogo macro'), findsOneWidget);
    expect(find.byType(NutrientRing), findsWidgets);
    expect(find.text('300 kcal'), findsOneWidget);
    expect(find.text('Obiettivo 600 kcal'), findsOneWidget);
    expect(find.text('15,0 g'), findsWidgets);
    expect(find.textContaining('Pranzo'), findsOneWidget);
    expect(find.text('Pasta integrale'), findsOneWidget);
  });
}
