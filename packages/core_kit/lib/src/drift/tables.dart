import 'package:drift/drift.dart';

class FoodItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get protein => real().withDefault(const Constant(0.0))();
  RealColumn get fat => real().withDefault(const Constant(0.0))();
  RealColumn get carbohydrates => real().withDefault(const Constant(0.0))();
  RealColumn get fiber => real().withDefault(const Constant(0.0))();
  RealColumn get sugar => real().withDefault(const Constant(0.0))();
  RealColumn get sodium => real().withDefault(const Constant(0.0))();
  RealColumn get servingSize => real()();
  TextColumn get servingUnit => text()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get allergens => text().withDefault(const Constant('[]'))();
  TextColumn get brand => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get protein => real().withDefault(const Constant(0.0))();
  RealColumn get fat => real().withDefault(const Constant(0.0))();
  RealColumn get carbohydrates => real().withDefault(const Constant(0.0))();
  RealColumn get fiber => real().withDefault(const Constant(0.0))();
  RealColumn get sugar => real().withDefault(const Constant(0.0))();
  RealColumn get sodium => real().withDefault(const Constant(0.0))();
  RealColumn get servingSize => real()();
  TextColumn get servingUnit => text()();
  TextColumn get instructions => text().withDefault(const Constant('[]'))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  IntColumn get prepTimeMinutes => integer().withDefault(const Constant(0))();
  IntColumn get cookTimeMinutes => integer().withDefault(const Constant(0))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MealEntries extends Table {
  TextColumn get id => text()();
  TextColumn get mealType => text()();
  DateTimeColumn get consumedAt => dateTime()();
  TextColumn get recipeId => text().nullable().references(Recipes, #id)();
  RealColumn get servings => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get weekStart => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  BoolColumn get isStaple => boolean().withDefault(const Constant(false))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get shoppingPlanId =>
      text().nullable().references(ShoppingPlans, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get preferredDiet => text()();
  TextColumn get shoppingDay =>
      text().withDefault(const Constant('monday'))();
  IntColumn get dailyCalorieTarget => integer()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get allergies => text().withDefault(const Constant('[]'))();
  TextColumn get dislikedIngredients =>
      text().withDefault(const Constant('[]'))();
  TextColumn get photoUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EventLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()();
  TextColumn get description => text()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  TextColumn get userId => text().nullable().references(UserProfiles, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get foodItemId => text().references(FoodItems, #id)();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get preparation => text().nullable()();
  TextColumn get recipeId => text().nullable().references(Recipes, #id)();
  TextColumn get mealEntryId => text().nullable().references(MealEntries, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
