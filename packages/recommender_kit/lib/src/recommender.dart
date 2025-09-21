import 'package:core_kit/core_kit.dart';
import 'package:meta/meta.dart';

/// Describes the context in which meal suggestions should be generated.
///
/// It contains the user profile, available recipes, nutritional targets
/// and recent meal history so that a recommender can make informed choices.
@immutable
class SuggestionContext {
  const SuggestionContext({
    required this.profile,
    required this.mealType,
    required List<Recipe> candidates,
    required this.targetMacros,
    this.consumedMacros = const Nutrients(),
    List<MealEntry> recentMeals = const <MealEntry>[],
    DateTime? referenceTime,
    this.recentMealWindow = const Duration(days: 2),
  })  : candidates = List<Recipe>.unmodifiable(candidates),
        recentMeals = List<MealEntry>.unmodifiable(recentMeals),
        referenceTime = referenceTime ?? DateTime.now();

  /// The profile to tailor meal suggestions for.
  final UserProfile profile;

  /// The meal that should be planned, e.g. breakfast or dinner.
  final MealType mealType;

  /// Candidate recipes to choose from.
  final List<Recipe> candidates;

  /// The nutrient target that the recommendation should aim for when the meal
  /// is included in the user's plan.
  final Nutrients targetMacros;

  /// Nutrients that have already been consumed for the day.
  final Nutrients consumedMacros;

  /// Meals logged recently. Used to diversify the output.
  final List<MealEntry> recentMeals;

  /// Reference time used to evaluate the recency of meals.
  final DateTime referenceTime;

  /// Window of time to consider a meal as "recent".
  final Duration recentMealWindow;
}

/// Describes a suggestion returned by a [Recommender].
@immutable
class MealSuggestion {
  const MealSuggestion({
    required this.recipe,
    required this.score,
    required this.reason,
  });

  /// Recipe that should be suggested to the user.
  final Recipe recipe;

  /// Heuristic score. Higher scores represent better matches.
  final double score;

  /// Human readable explanation of why the recipe was suggested.
  final String reason;
}

/// Contract implemented by meal recommendation strategies.
abstract class Recommender {
  /// Returns a ranked list of meal suggestions based on the provided [context].
  Future<List<MealSuggestion>> recommend(SuggestionContext context);
}
