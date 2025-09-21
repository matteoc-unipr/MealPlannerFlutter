import 'package:core_kit/core_kit.dart';
import 'package:data_kit/data_kit.dart';
import 'package:drift/drift.dart';
import 'package:recommender_kit/recommender_kit.dart';
import 'package:test/test.dart';

void main() {
  group('HeuristicRecommender', () {
    late HeuristicRecommender recommender;

    setUp(() {
      recommender = const HeuristicRecommender();
    });

    test('rispetta dieta, allergie e ingredienti sgraditi', () async {
      final profile = UserProfile.create(
        name: 'Test',
        preferredDiet: DietModel.vegetarian,
        shoppingDay: Weekday.saturday,
        dailyCalorieTarget: 2000,
        heightCm: 170,
        weightKg: 68,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
        allergies: const ['Peanuts'],
        dislikedIngredients: const ['mushroom'],
      );

      final chickpea = FoodItem.create(
        name: 'Chickpeas',
        nutrients: const Nutrients(
          calories: 220,
          protein: 12,
          fat: 6,
          carbohydrates: 34,
        ),
        servingSize: 100,
        servingUnit: UnitType.gram,
        tags: const ['vegetarian', 'dinner'],
      );

      final chicken = FoodItem.create(
        name: 'Chicken Breast',
        nutrients: const Nutrients(calories: 165, protein: 31, fat: 4, carbohydrates: 0),
        servingSize: 100,
        servingUnit: UnitType.gram,
        tags: const ['meat'],
      );

      final peanuts = FoodItem.create(
        name: 'Peanuts',
        nutrients: const Nutrients(calories: 300, protein: 13, fat: 26, carbohydrates: 8),
        servingSize: 50,
        servingUnit: UnitType.gram,
        allergens: const ['peanuts'],
      );

      final mushroom = FoodItem.create(
        name: 'Mushroom',
        nutrients: const Nutrients(calories: 20, protein: 3, fat: 0, carbohydrates: 2),
        servingSize: 50,
        servingUnit: UnitType.gram,
      );

      final safeRecipe = Recipe.create(
        title: 'Zuppa di ceci',
        description: 'Zuppa calda e proteica.',
        nutrients: const Nutrients(
          calories: 450,
          protein: 20,
          fat: 10,
          carbohydrates: 60,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
        ingredients: [
          Ingredient.create(item: chickpea, quantity: 150, unit: UnitType.gram),
        ],
        tags: const ['vegetarian', 'dinner'],
      );

      final meatRecipe = Recipe.create(
        title: 'Pollo grigliato',
        description: 'Ricco di proteine.',
        nutrients: const Nutrients(
          calories: 350,
          protein: 40,
          fat: 6,
          carbohydrates: 2,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
        ingredients: [
          Ingredient.create(item: chicken, quantity: 150, unit: UnitType.gram),
        ],
        tags: const ['lunch'],
      );

      final allergenRecipe = Recipe.create(
        title: 'Pad thai alle arachidi',
        description: 'Contiene frutta secca.',
        nutrients: const Nutrients(
          calories: 520,
          protein: 18,
          fat: 22,
          carbohydrates: 60,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
        ingredients: [
          Ingredient.create(item: peanuts, quantity: 60, unit: UnitType.gram),
        ],
        tags: const ['dinner'],
      );

      final dislikedRecipe = Recipe.create(
        title: 'Crema di funghi',
        description: 'Sapori terrosi.',
        nutrients: const Nutrients(
          calories: 300,
          protein: 10,
          fat: 12,
          carbohydrates: 30,
        ),
        servingSize: 1,
        servingUnit: UnitType.serving,
        ingredients: [
          Ingredient.create(item: mushroom, quantity: 120, unit: UnitType.gram),
        ],
        tags: const ['dinner'],
      );

      final context = SuggestionContext(
        profile: profile,
        mealType: MealType.dinner,
        candidates: [safeRecipe, meatRecipe, allergenRecipe, dislikedRecipe],
        targetMacros: const Nutrients(
          calories: 600,
          protein: 25,
          fat: 20,
          carbohydrates: 70,
        ),
        consumedMacros: const Nutrients(
          calories: 200,
          protein: 8,
          fat: 5,
          carbohydrates: 25,
        ),
      );

      final suggestions = await recommender.recommend(context);

      expect(suggestions, hasLength(1));
      expect(suggestions.single.recipe.title, 'Zuppa di ceci');
      expect(suggestions.single.reason, isNotEmpty);
    });

    test('evita ripetizioni recenti quando ci sono alternative', () async {
      final profile = UserProfile.create(
        name: 'Mario',
        preferredDiet: DietModel.omnivore,
        shoppingDay: Weekday.friday,
        dailyCalorieTarget: 2200,
        heightCm: 175,
        weightKg: 75,
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      Recipe buildRecipe(String id, String title, double calories) {
        return Recipe.create(
          id: id,
          title: title,
          description: 'Ricetta $title',
          nutrients: Nutrients(
            calories: calories,
            protein: 20,
            fat: 12,
            carbohydrates: 45,
          ),
          servingSize: 1,
          servingUnit: UnitType.serving,
          ingredients: [
            Ingredient.create(
              item: FoodItem.create(
                name: title,
                nutrients: Nutrients(calories: calories, protein: 10, fat: 5, carbohydrates: 20),
                servingSize: 1,
                servingUnit: UnitType.serving,
                tags: const ['lunch'],
              ),
              quantity: 1,
              unit: UnitType.serving,
            ),
          ],
          tags: const ['lunch'],
        );
      }

      final recipes = [
        buildRecipe('a', 'Insalata di quinoa', 420),
        buildRecipe('b', 'Pasta al pesto', 550),
        buildRecipe('c', 'Zuppa di lenticchie', 380),
        buildRecipe('d', 'Tofu saltato', 400),
      ];

      final now = DateTime.utc(2024, 1, 10, 12);
      final context = SuggestionContext(
        profile: profile,
        mealType: MealType.lunch,
        candidates: recipes,
        targetMacros: const Nutrients(
          calories: 650,
          protein: 30,
          fat: 25,
          carbohydrates: 80,
        ),
        consumedMacros: const Nutrients(
          calories: 500,
          protein: 22,
          fat: 15,
          carbohydrates: 55,
        ),
        recentMeals: [
          MealEntry.create(
            mealType: MealType.lunch,
            consumedAt: now.subtract(const Duration(hours: 6)),
            recipeId: 'a',
          ),
        ],
        referenceTime: now,
      );

      final suggestions = await recommender.recommend(context);

      expect(suggestions, hasLength(3));
      expect(suggestions.map((s) => s.recipe.id), isNot(contains('a')));
    });
  });

  group('recordFeedback', () {
    tearDown(() async {
      await closeDatabase();
    });

    test('memorizza eventi nel registro', () async {
      final db = await initDatabase(reset: true);
      final event = EventLog.create(
        timestamp: DateTime.utc(2024, 2, 1, 12),
        type: 'feedback',
        description: 'L\'utente apprezza la proposta.',
        metadata: const {'rating': 5},
        userId: 'user-123',
      );

      await recordFeedback(event);

      final row = await db
          .customSelect(
            'SELECT * FROM event_logs WHERE id = ? LIMIT 1',
            variables: [Variable<String>(event.id)],
            readsFrom: {db.eventLogs},
          )
          .getSingleOrNull();

      expect(row, isNotNull);
      final stored = db.mapEventLog(Map<String, dynamic>.from(row!.data));
      expect(stored.id, event.id);
      expect(stored.type, 'feedback');
      expect(stored.metadata['rating'], 5);
    });
  });
}
