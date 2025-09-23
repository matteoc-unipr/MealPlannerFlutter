import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meals_feature/meals_feature.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:shopping_feature/shopping_feature.dart';

class _FlowDependencies {
  _FlowDependencies({
    required this.repository,
    required this.shoppingService,
    required this.plannedMeals,
    required this.profile,
    required this.diaryDate,
    required this.suggestedRecipe,
    required this.exportPath,
  });

  final MealsRepository repository;
  final ShoppingService shoppingService;
  final List<MealEntry> plannedMeals;
  final UserProfile profile;
  final DateTime diaryDate;
  final Recipe suggestedRecipe;
  final String exportPath;
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SettingsScreen(
        exportJson: () async => <String, dynamic>{'profiles': 1},
        eraseAll: () async {},
        exportPath: deps.exportPath,
        initialKcalTarget: 0,
        initialMacroTargets: const Nutrients(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Continue',
        heroTag: 'onboarding-next',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _AddMealScreen(deps: deps),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class _AddMealScreen extends StatelessWidget {
  const _AddMealScreen({required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add meal')),
      body: AddMealFlow(
        onScan: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Scan selected')));
        },
        onSearch: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Search selected')));
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _DiaryScreen(deps: deps),
            ),
          );
        },
        onRecipes: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Recipes selected')));
        },
        onQuickAdd: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quick add selected')));
        },
      ),
    );
  }
}

class _DiaryScreen extends StatelessWidget {
  const _DiaryScreen({required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary')),
      body: DailyDiaryScreen(repository: deps.repository, date: deps.diaryDate),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Next step',
        heroTag: 'diary-next',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _AcceptSuggestionScreen(deps: deps),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class _AcceptSuggestionScreen extends StatelessWidget {
  const _AcceptSuggestionScreen({required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RecipeDetailScreen(
        recipe: deps.suggestedRecipe,
        mealsRepository: deps.repository,
        mealType: MealType.dinner,
        consumedAt: deps.diaryDate.add(const Duration(hours: 19)),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Shopping list',
        heroTag: 'accept-next',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ShoppingListScreen(deps: deps),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _ShoppingListScreen extends StatelessWidget {
  const _ShoppingListScreen({required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    final summary = deps.shoppingService.buildSummary(
      plannedMeals: deps.plannedMeals,
      profile: deps.profile,
      planStart: deps.diaryDate,
      reference: deps.diaryDate,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping list')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
              'Next shopping date: ${summary.nextShoppingDate.toIso8601String()}'),
          const SizedBox(height: 16),
          ...summary.plan.items.map(
            (item) => ListTile(
              title: Text(item.name),
              subtitle: Text(
                '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit.name}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntegrationFlowApp extends StatelessWidget {
  const IntegrationFlowApp({super.key, required this.deps});

  final _FlowDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _OnboardingScreen(deps: deps),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late MealEntryDao mealEntryDao;
  late MealsRepository mealsRepository;
  late ShoppingService shoppingService;
  late List<MealEntry> plannedMeals;
  late Recipe suggestedRecipe;
  late UserProfile profile;
  final exportFile = File('integration_export.json');

  setUpAll(() async {
    database =
        await initDatabase(executor: NativeDatabase.memory(), reset: true);
    mealEntryDao = MealEntryDao(database);
    mealsRepository = MealsRepository(mealEntryDao);
    shoppingService = ShoppingService(now: () => DateTime.utc(2024, 1, 1));

    final oats = FoodItem.create(
      name: 'Oats',
      nutrients: const Nutrients(
        calories: 150,
        protein: 5,
        fat: 3,
        carbohydrates: 27,
      ),
      servingSize: 50,
      servingUnit: UnitType.gram,
    );
    final yogurt = FoodItem.create(
      name: 'Greek Yogurt',
      nutrients: const Nutrients(
        calories: 120,
        protein: 12,
        fat: 4,
        carbohydrates: 8,
      ),
      servingSize: 1,
      servingUnit: UnitType.serving,
    );

    final breakfast = MealEntry.create(
      mealType: MealType.breakfast,
      consumedAt: DateTime.utc(2024, 1, 1, 8),
      ingredients: <Ingredient>[
        Ingredient.create(item: oats, quantity: 60, unit: UnitType.gram),
        Ingredient.create(item: yogurt, quantity: 1, unit: UnitType.serving),
      ],
    );

    await mealEntryDao.upsertMealEntry(breakfast);
    await mealsRepository.refresh();

    profile = UserProfile.create(
      name: 'Alice',
      preferredDiet: DietModel.omnivore,
      shoppingDay: Weekday.friday,
      dailyCalorieTarget: 2000,
      heightCm: 165,
      weightKg: 60,
      createdAt: DateTime.utc(2023, 12, 1),
      updatedAt: DateTime.utc(2023, 12, 15),
    );

    final salad = FoodItem.create(
      name: 'Quinoa salad',
      nutrients: const Nutrients(
        calories: 420,
        protein: 16,
        fat: 12,
        carbohydrates: 60,
      ),
      servingSize: 1,
      servingUnit: UnitType.serving,
      tags: const <String>['dinner'],
    );

    suggestedRecipe = Recipe.create(
      title: 'Planner suggestion',
      description: 'Balanced dinner option.',
      nutrients: salad.nutrients,
      servingSize: 1,
      servingUnit: UnitType.serving,
      ingredients: <Ingredient>[
        Ingredient.create(item: salad, quantity: 1, unit: UnitType.serving),
      ],
      instructions: const <String>['Serve and enjoy'],
      tags: const <String>['dinner'],
    );

    plannedMeals = <MealEntry>[
      breakfast,
      MealEntry.create(
        mealType: MealType.lunch,
        consumedAt: DateTime.utc(2024, 1, 2, 12),
        ingredients: <Ingredient>[
          Ingredient.create(item: salad, quantity: 1, unit: UnitType.serving),
        ],
      ),
      MealEntry.create(
        mealType: MealType.dinner,
        consumedAt: DateTime.utc(2024, 1, 3, 19),
        ingredients: <Ingredient>[
          Ingredient.create(item: oats, quantity: 50, unit: UnitType.gram),
        ],
      ),
    ];
  });

  tearDownAll(() async {
    await mealsRepository.dispose();
    await closeDatabase();
    if (await exportFile.exists()) {
      await exportFile.delete();
    }
  });

  testWidgets('full onboarding to shopping flow', (tester) async {
    final deps = _FlowDependencies(
      repository: mealsRepository,
      shoppingService: shoppingService,
      plannedMeals: plannedMeals,
      profile: profile,
      diaryDate: DateTime.utc(2024, 1, 1),
      suggestedRecipe: suggestedRecipe,
      exportPath: exportFile.path,
    );

    await tester.pumpWidget(IntegrationFlowApp(deps: deps));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('settings_kcal_field')), '1900');
    await tester.tap(find.byKey(const Key('settings_health_toggle')));
    await tester.tap(find.byTooltip('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search selected'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Macro summary'), findsOneWidget);
    await tester.tap(find.byTooltip('Next step'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to meal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Recipe added to diary.'), findsOneWidget);

    await tester.tap(find.byTooltip('Shopping list'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Shopping list'), findsOneWidget);
    expect(find.text('Quinoa salad'), findsWidgets);
    expect(find.textContaining('piece'), findsWidgets);
  });
}
