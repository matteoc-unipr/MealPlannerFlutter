import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core_kit/core_kit.dart';

import 'recommender.dart';

/// Simple rule-based recommender that balances nutritional targets while
/// respecting dietary restrictions and recent meal history.
class HeuristicRecommender implements Recommender {
  const HeuristicRecommender();

  static const int _maxSuggestions = 3;

  @override
  Future<List<MealSuggestion>> recommend(SuggestionContext context) async {
    final filtered = _filterCandidates(context);
    if (filtered.isEmpty) {
      return <MealSuggestion>[];
    }

    final Set<String> recentIds = _recentRecipeIds(context);

    final suggestions = filtered
        .map(
          (recipe) => MealSuggestion(
            recipe: recipe,
            score: _scoreRecipe(
              recipe,
              context,
              isRecent: recentIds.contains(recipe.id),
            ),
            reason: _buildReason(
              recipe,
              context,
              isRecent: recentIds.contains(recipe.id),
            ),
          ),
        )
        .toList();

    suggestions.sort((a, b) => b.score.compareTo(a.score));

    final result = <MealSuggestion>[];
    for (final suggestion in suggestions) {
      if (result.length >= _maxSuggestions) {
        break;
      }
      if (recentIds.contains(suggestion.recipe.id)) {
        continue;
      }
      result.add(suggestion);
    }

    if (result.length < _maxSuggestions) {
      for (final suggestion in suggestions) {
        if (result.length >= _maxSuggestions) {
          break;
        }
        if (result.any((s) => s.recipe.id == suggestion.recipe.id)) {
          continue;
        }
        result.add(suggestion);
      }
    }

    return result;
  }
}

List<Recipe> _filterCandidates(SuggestionContext context) {
  return context.candidates.where((recipe) {
    if (!_matchesDiet(recipe, context.profile.preferredDiet)) {
      return false;
    }
    if (_containsAllergens(recipe, context.profile.allergies)) {
      return false;
    }
    if (_containsDisliked(recipe, context.profile.dislikedIngredients)) {
      return false;
    }
    return true;
  }).toList();
}

Set<String> _recentRecipeIds(SuggestionContext context) {
  if (context.recentMeals.isEmpty) {
    return <String>{};
  }
  final threshold = context.referenceTime.subtract(context.recentMealWindow);
  return context.recentMeals
      .where((meal) => meal.recipeId != null && meal.consumedAt.isAfter(threshold))
      .map((meal) => meal.recipeId!)
      .toSet();
}

const Map<DietModel, Set<String>> _dietTags = <DietModel, Set<String>>{
  DietModel.vegetarian: {'vegetarian'},
  DietModel.vegan: {'vegan'},
  DietModel.pescetarian: {'pescetarian', 'seafood'},
  DietModel.keto: {'keto', 'low-carb', 'low carb'},
  DietModel.paleo: {'paleo'},
  DietModel.mediterranean: {'mediterranean'},
  DietModel.glutenFree: {'gluten-free', 'gluten free'},
};

const Set<String> _meatKeywords = <String>{
  'bacon',
  'beef',
  'chicken',
  'ham',
  'lamb',
  'pancetta',
  'pork',
  'prosciutto',
  'salami',
  'sausage',
  'steak',
  'turkey',
  'veal',
};

const Set<String> _seafoodKeywords = <String>{
  'anchovy',
  'cod',
  'fish',
  'mackerel',
  'prawn',
  'salmon',
  'shrimp',
  'tuna',
};

const Set<String> _animalProductKeywords = <String>{
  'butter',
  'cheese',
  'egg',
  'gelatin',
  'honey',
  'milk',
  'yogurt',
};

const Set<String> _grainKeywords = <String>{
  'barley',
  'bread',
  'bulgur',
  'cereal',
  'corn',
  'couscous',
  'farro',
  'noodle',
  'oat',
  'pasta',
  'rice',
  'rye',
  'spelt',
  'wheat',
};

const Set<String> _glutenKeywords = <String>{
  'barley',
  'farro',
  'gluten',
  'rye',
  'spelt',
  'wheat',
};

const Set<String> _highCarbKeywords = <String>{
  'bread',
  'pasta',
  'potato',
  'rice',
  'sugar',
};

bool _matchesDiet(Recipe recipe, DietModel diet) {
  final tags = _normalizedRecipeTags(recipe);
  final tagMatches = _dietTags[diet];
  if (tagMatches != null && tags.any(tagMatches.contains)) {
    return true;
  }

  switch (diet) {
    case DietModel.omnivore:
      return true;
    case DietModel.vegetarian:
      return !_containsAny(recipe, _meatKeywords) &&
          !_containsAny(recipe, _seafoodKeywords);
    case DietModel.vegan:
      return _matchesDiet(recipe, DietModel.vegetarian) &&
          !_containsAny(recipe, _animalProductKeywords);
    case DietModel.pescetarian:
      return !_containsAny(recipe, _meatKeywords);
    case DietModel.keto:
      if (recipe.nutrients.carbohydrates > 25) {
        return false;
      }
      return !_containsAny(recipe, _highCarbKeywords);
    case DietModel.paleo:
      return !_containsAny(recipe, _grainKeywords) &&
          !_containsAny(recipe, _highCarbKeywords);
    case DietModel.mediterranean:
      return true;
    case DietModel.glutenFree:
      return !_containsAllergenKeyword(recipe, 'gluten') &&
          !_containsAny(recipe, _glutenKeywords);
  }
}

bool _containsAllergens(Recipe recipe, Iterable<String> allergies) {
  final targets = allergies
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();
  if (targets.isEmpty) {
    return false;
  }

  for (final ingredient in recipe.ingredients) {
    final item = ingredient.item;
    for (final allergen in item.allergens) {
      final normalized = allergen.toLowerCase();
      if (targets.any((needle) => normalized.contains(needle))) {
        return true;
      }
    }
    final name = item.name.toLowerCase();
    if (targets.any(name.contains)) {
      return true;
    }
  }
  return false;
}

bool _containsDisliked(Recipe recipe, Iterable<String> disliked) {
  final targets = disliked
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet();
  if (targets.isEmpty) {
    return false;
  }

  final ingredientNames = recipe.ingredients
      .map((ingredient) => ingredient.item.name.toLowerCase())
      .toList();
  final tags = _normalizedRecipeTags(recipe);

  for (final target in targets) {
    if (ingredientNames.any((name) => name.contains(target))) {
      return true;
    }
    if (tags.any((tag) => tag.contains(target))) {
      return true;
    }
  }
  return false;
}

bool _containsAny(Recipe recipe, Set<String> keywords) {
  if (keywords.isEmpty) {
    return false;
  }
  final names = recipe.ingredients
      .map((ingredient) => ingredient.item.name.toLowerCase())
      .toList();
  final tags = _normalizedRecipeTags(recipe);
  return keywords.any(
    (keyword) =>
        names.any((name) => name.contains(keyword)) ||
        tags.any((tag) => tag.contains(keyword)),
  );
}

bool _containsAllergenKeyword(Recipe recipe, String keyword) {
  final target = keyword.toLowerCase();
  for (final ingredient in recipe.ingredients) {
    for (final allergen in ingredient.item.allergens) {
      if (allergen.toLowerCase().contains(target)) {
        return true;
      }
    }
  }
  return false;
}

Set<String> _normalizedRecipeTags(Recipe recipe) {
  final tags = <String>{};
  tags.addAll(recipe.tags.map((tag) => tag.toLowerCase()));
  for (final ingredient in recipe.ingredients) {
    tags.addAll(ingredient.item.tags.map((tag) => tag.toLowerCase()));
  }
  return tags;
}

Nutrients _addNutrients(Nutrients a, Nutrients b) {
  return Nutrients(
    calories: a.calories + b.calories,
    protein: a.protein + b.protein,
    fat: a.fat + b.fat,
    carbohydrates: a.carbohydrates + b.carbohydrates,
    fiber: a.fiber + b.fiber,
    sugar: a.sugar + b.sugar,
    sodium: a.sodium + b.sodium,
  );
}

Map<String, double> _macroDifferences(Nutrients actual, Nutrients target) {
  return <String, double>{
    'calorie': _normalizedDiff(actual.calories, target.calories),
    'proteine': _normalizedDiff(actual.protein, target.protein),
    'grassi': _normalizedDiff(actual.fat, target.fat),
    'carboidrati': _normalizedDiff(actual.carbohydrates, target.carbohydrates),
  };
}

double _normalizedDiff(double actual, double target) {
  final double denominator = max(target.abs(), 1.0);
  return (actual - target).abs() / denominator;
}

double _scoreRecipe(
  Recipe recipe,
  SuggestionContext context, {
  required bool isRecent,
}) {
  final combined = _addNutrients(context.consumedMacros, recipe.nutrients);
  final after = _macroDifferences(combined, context.targetMacros);
  final before = _macroDifferences(context.consumedMacros, context.targetMacros);

  final double sumAfter = after.values.sum;
  final double sumBefore = before.values.sum;
  final double improvement = (sumBefore - sumAfter).clamp(-1.0, 1.0);
  final double balance = 1 / (1 + sumAfter);

  final double dietAffinity = _dietAffinity(recipe, context.profile.preferredDiet);
  final double mealTypeAffinity = _mealTypeAffinity(recipe, context.mealType);

  double score = balance + improvement + dietAffinity + mealTypeAffinity;
  score += isRecent ? -0.5 : 0.2;
  return max(score, 0);
}

double _dietAffinity(Recipe recipe, DietModel diet) {
  final tags = _normalizedRecipeTags(recipe);
  final tagMatches = _dietTags[diet];
  if (tagMatches == null) {
    return 0;
  }
  return tags.any(tagMatches.contains) ? 0.15 : 0;
}

double _mealTypeAffinity(Recipe recipe, MealType mealType) {
  final tags = _normalizedRecipeTags(recipe);
  return tags.contains(mealType.name) ? 0.1 : 0;
}

String _buildReason(
  Recipe recipe,
  SuggestionContext context, {
  required bool isRecent,
}) {
  final combined = _addNutrients(context.consumedMacros, recipe.nutrients);
  final after = _macroDifferences(combined, context.targetMacros);
  final before = _macroDifferences(context.consumedMacros, context.targetMacros);

  final improvements = <String, double>{};
  after.forEach((macro, value) {
    final previous = before[macro] ?? value;
    improvements[macro] = previous - value;
  });

  final best = improvements.entries
      .sorted((a, b) => b.value.compareTo(a.value))
      .first;

  if (best.value > 0.05) {
    return 'Riduce lo scostamento di ${best.key} rispetto al target.';
  }

  if (!isRecent) {
    return 'Aggiunge varietà rispetto ai pasti recenti.';
  }

  return 'Bilanciamento nutrizionale stabile.';
}
