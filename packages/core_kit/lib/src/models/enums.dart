/// Enumerations that describe common units, diets, and planning states
/// shared across the Assistente Alimentare domain models.
enum UnitType {
  gram,
  milliliter,
  ounce,
  pound,
  piece,
  cup,
  tablespoon,
  teaspoon,
  serving,
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

enum DietModel {
  omnivore,
  vegetarian,
  vegan,
  pescetarian,
  keto,
  paleo,
  mediterranean,
  glutenFree,
}

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum PlanStatus {
  pending,
  active,
  completed,
  cancelled,
}
