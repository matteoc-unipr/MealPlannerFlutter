import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_feature/shopping_feature.dart';

class _ShoppingListPreview extends StatelessWidget {
  const _ShoppingListPreview({
    required this.service,
    required this.plannedMeals,
    required this.profile,
    required this.planStart,
    required this.reference,
  });

  final ShoppingService service;
  final Iterable<MealEntry> plannedMeals;
  final UserProfile profile;
  final DateTime planStart;
  final DateTime reference;

  @override
  Widget build(BuildContext context) {
    final summary = service.buildSummary(
      plannedMeals: plannedMeals,
      profile: profile,
      planStart: planStart,
      reference: reference,
    );

    return Material(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Next shopping: ${summary.nextShoppingDate.toIso8601String()}'),
          const SizedBox(height: 12),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('aggregates planned meals into a shopping list preview',
      (tester) async {
    final service = ShoppingService(now: () => DateTime.utc(2024, 1, 1));
    final profile = UserProfile.create(
      name: 'Alice',
      preferredDiet: DietModel.omnivore,
      shoppingDay: Weekday.friday,
      dailyCalorieTarget: 2000,
      heightCm: 165,
      weightKg: 60,
      createdAt: DateTime.utc(2023, 12, 1),
      updatedAt: DateTime.utc(2023, 12, 15),
    );

    FoodItem buildItem(String id, String name) {
      return FoodItem(
        id: id,
        name: name,
        nutrients: const Nutrients(calories: 50),
        servingSize: 1,
        servingUnit: UnitType.piece,
      );
    }

    MealEntry buildMeal(DateTime consumedAt, List<Ingredient> ingredients) {
      return MealEntry(
        id: 'meal-${consumedAt.toIso8601String()}',
        mealType: MealType.lunch,
        consumedAt: consumedAt,
        ingredients: ingredients,
      );
    }

    final apple = buildItem('apple', 'Apple');
    final banana = buildItem('banana', 'Banana');

    final meals = <MealEntry>[
      buildMeal(
        DateTime.utc(2024, 1, 1, 8),
        <Ingredient>[
          Ingredient(
            id: 'ing-apple-1',
            item: apple,
            quantity: 2,
            unit: UnitType.piece,
          ),
        ],
      ),
      buildMeal(
        DateTime.utc(2024, 1, 2, 8),
        <Ingredient>[
          Ingredient(
            id: 'ing-banana-1',
            item: banana,
            quantity: 3,
            unit: UnitType.piece,
          ),
        ],
      ),
      buildMeal(
        DateTime.utc(2024, 1, 3, 8),
        <Ingredient>[
          Ingredient(
            id: 'ing-apple-2',
            item: apple,
            quantity: 1,
            unit: UnitType.piece,
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _ShoppingListPreview(
          service: service,
          plannedMeals: meals,
          profile: profile,
          planStart: DateTime.utc(2024, 1, 1),
          reference: DateTime.utc(2024, 1, 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Next shopping'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('3 piece'), findsNWidgets(2));
  });
}
