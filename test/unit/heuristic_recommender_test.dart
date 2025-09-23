import 'package:core_kit/core_kit.dart';
import 'package:recommender_kit/recommender_kit.dart';
import 'package:test/test.dart';

Recipe _buildRecipe({
  required String id,
  required String title,
  required Nutrients nutrients,
  List<String> tags = const <String>[],
  List<Ingredient>? ingredients,
}) {
  final ingredient = Ingredient.create(
    item: FoodItem.create(
      id: 'food-$id',
      name: title,
      nutrients: nutrients,
      servingSize: 1,
      servingUnit: UnitType.serving,
      tags: tags,
    ),
    quantity: 1,
    unit: UnitType.serving,
  );
  return Recipe.create(
    id: id,
    title: title,
    description: '$title description',
    nutrients: nutrients,
    servingSize: 1,
    servingUnit: UnitType.serving,
    ingredients: ingredients ?? <Ingredient>[ingredient],
    tags: tags,
  );
}

void main() {
  group('HeuristicRecommender', () {
    const recommender = HeuristicRecommender();

    test('filters out recipes that violate diet or allergies', () async {
      final profile = UserProfile.create(
        name: 'Test',
        preferredDiet: DietModel.vegan,
        shoppingDay: Weekday.sunday,
        dailyCalorieTarget: 2200,
        heightCm: 170,
        weightKg: 68,
        allergies: const <String>['peanut'],
        dislikedIngredients: const <String>['mushroom'],
      );

      final veganRecipe = _buildRecipe(
        id: 'vegan',
        title: 'Quinoa bowl',
        nutrients: const Nutrients(
            calories: 480, protein: 18, fat: 12, carbohydrates: 70),
        tags: const <String>['vegan', 'lunch'],
      );
      final peanutRecipe = _buildRecipe(
        id: 'peanut',
        title: 'Peanut curry',
        nutrients: const Nutrients(
            calories: 520, protein: 20, fat: 22, carbohydrates: 55),
        ingredients: <Ingredient>[
          Ingredient.create(
            item: FoodItem.create(
              name: 'Peanut sauce',
              nutrients: const Nutrients(calories: 100),
              servingSize: 1,
              servingUnit: UnitType.serving,
              allergens: const <String>['peanut'],
            ),
            quantity: 1,
            unit: UnitType.serving,
          ),
        ],
      );
      final mushroomRecipe = _buildRecipe(
        id: 'mushroom',
        title: 'Mushroom risotto',
        nutrients: const Nutrients(
            calories: 530, protein: 15, fat: 18, carbohydrates: 75),
        tags: const <String>['dinner'],
        ingredients: <Ingredient>[
          Ingredient.create(
            item: FoodItem.create(
              name: 'Porcini mushroom',
              nutrients: const Nutrients(calories: 50),
              servingSize: 100,
              servingUnit: UnitType.gram,
            ),
            quantity: 1,
            unit: UnitType.serving,
          ),
        ],
      );

      final context = SuggestionContext(
        profile: profile,
        mealType: MealType.lunch,
        candidates: <Recipe>[veganRecipe, peanutRecipe, mushroomRecipe],
        targetMacros: const Nutrients(
            calories: 700, protein: 25, fat: 25, carbohydrates: 90),
        consumedMacros: const Nutrients(
            calories: 400, protein: 12, fat: 10, carbohydrates: 40),
        referenceTime: DateTime.utc(2024, 1, 1, 12),
        recentMeals: const <MealEntry>[],
      );

      final suggestions = await recommender.recommend(context);

      expect(suggestions, hasLength(1));
      expect(suggestions.single.recipe.id, 'vegan');
      expect(suggestions.single.reason,
          contains('varietà').or(contains('Riduce')));
    });

    test('returns at most three ranked suggestions', () async {
      final profile = UserProfile.create(
        name: 'Mario',
        preferredDiet: DietModel.omnivore,
        shoppingDay: Weekday.friday,
        dailyCalorieTarget: 2100,
        heightCm: 175,
        weightKg: 74,
      );

      final recipes = <Recipe>[
        _buildRecipe(
          id: 'a',
          title: 'Lentil soup',
          nutrients: const Nutrients(
              calories: 380, protein: 24, fat: 8, carbohydrates: 55),
          tags: const <String>['dinner'],
        ),
        _buildRecipe(
          id: 'b',
          title: 'Grilled salmon',
          nutrients: const Nutrients(
              calories: 420, protein: 34, fat: 16, carbohydrates: 10),
          tags: const <String>['lunch', 'seafood'],
        ),
        _buildRecipe(
          id: 'c',
          title: 'Pasta pesto',
          nutrients: const Nutrients(
              calories: 640, protein: 18, fat: 28, carbohydrates: 82),
          tags: const <String>['lunch'],
        ),
        _buildRecipe(
          id: 'd',
          title: 'Veggie tacos',
          nutrients: const Nutrients(
              calories: 510, protein: 20, fat: 14, carbohydrates: 70),
          tags: const <String>['dinner'],
        ),
      ];

      final context = SuggestionContext(
        profile: profile,
        mealType: MealType.dinner,
        candidates: recipes,
        targetMacros: const Nutrients(
            calories: 650, protein: 30, fat: 22, carbohydrates: 90),
        consumedMacros: const Nutrients(
            calories: 350, protein: 15, fat: 12, carbohydrates: 45),
        referenceTime: DateTime.utc(2024, 1, 2, 19),
        recentMeals: const <MealEntry>[],
      );

      final suggestions = await recommender.recommend(context);

      expect(suggestions, hasLength(3));
      expect(suggestions[0].score, greaterThanOrEqualTo(suggestions[1].score));
      expect(suggestions[1].score, greaterThanOrEqualTo(suggestions[2].score));
      expect(suggestions.map((s) => s.recipe.id),
          everyElement(isIn(recipes.map((r) => r.id))));
    });

    test('avoids recently used recipes when alternatives exist', () async {
      final profile = UserProfile.create(
        name: 'Luisa',
        preferredDiet: DietModel.omnivore,
        shoppingDay: Weekday.wednesday,
        dailyCalorieTarget: 2000,
        heightCm: 168,
        weightKg: 60,
      );

      final recipes = <Recipe>[
        _buildRecipe(
          id: 'recent',
          title: 'Recent bowl',
          nutrients: const Nutrients(
              calories: 500, protein: 25, fat: 15, carbohydrates: 65),
          tags: const <String>['lunch'],
        ),
        _buildRecipe(
          id: 'fresh',
          title: 'Fresh wrap',
          nutrients: const Nutrients(
              calories: 480, protein: 22, fat: 14, carbohydrates: 60),
          tags: const <String>['lunch'],
        ),
      ];

      final now = DateTime.utc(2024, 1, 5, 13);
      final recentMeal = MealEntry.create(
        mealType: MealType.lunch,
        consumedAt: now.subtract(const Duration(days: 1)),
        ingredients: const <Ingredient>[],
        recipeId: 'recent',
      );

      final context = SuggestionContext(
        profile: profile,
        mealType: MealType.lunch,
        candidates: recipes,
        targetMacros: const Nutrients(
            calories: 600, protein: 28, fat: 20, carbohydrates: 75),
        consumedMacros: const Nutrients(
            calories: 320, protein: 12, fat: 8, carbohydrates: 40),
        recentMeals: <MealEntry>[recentMeal],
        referenceTime: now,
        recentMealWindow: const Duration(days: 7),
      );

      final suggestions = await recommender.recommend(context);

      expect(suggestions.map((s) => s.recipe.id), contains('fresh'));
      expect(suggestions.map((s) => s.recipe.id), isNot(contains('recent')));
    });
  });
}
