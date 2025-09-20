CREATE TABLE food_items (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  calories REAL NOT NULL DEFAULT 0.0,
  protein REAL NOT NULL DEFAULT 0.0,
  fat REAL NOT NULL DEFAULT 0.0,
  carbohydrates REAL NOT NULL DEFAULT 0.0,
  fiber REAL NOT NULL DEFAULT 0.0,
  sugar REAL NOT NULL DEFAULT 0.0,
  sodium REAL NOT NULL DEFAULT 0.0,
  serving_size REAL NOT NULL,
  serving_unit TEXT NOT NULL,
  tags TEXT NOT NULL DEFAULT '[]',
  allergens TEXT NOT NULL DEFAULT '[]',
  brand TEXT,
  description TEXT,
  image_url TEXT
);

CREATE TABLE recipes (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  calories REAL NOT NULL DEFAULT 0.0,
  protein REAL NOT NULL DEFAULT 0.0,
  fat REAL NOT NULL DEFAULT 0.0,
  carbohydrates REAL NOT NULL DEFAULT 0.0,
  fiber REAL NOT NULL DEFAULT 0.0,
  sugar REAL NOT NULL DEFAULT 0.0,
  sodium REAL NOT NULL DEFAULT 0.0,
  serving_size REAL NOT NULL,
  serving_unit TEXT NOT NULL,
  instructions TEXT NOT NULL DEFAULT '[]',
  tags TEXT NOT NULL DEFAULT '[]',
  prep_time_minutes INTEGER NOT NULL DEFAULT 0,
  cook_time_minutes INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  source_url TEXT
);

CREATE TABLE meal_entries (
  id TEXT NOT NULL PRIMARY KEY,
  meal_type TEXT NOT NULL,
  consumed_at INTEGER NOT NULL,
  recipe_id TEXT REFERENCES recipes(id),
  servings REAL,
  notes TEXT
);

CREATE TABLE shopping_plans (
  id TEXT NOT NULL PRIMARY KEY,
  week_start TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER,
  completed_at INTEGER,
  notes TEXT
);

CREATE TABLE pantry_items (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  quantity REAL NOT NULL,
  unit TEXT NOT NULL,
  is_staple INTEGER NOT NULL DEFAULT 0,
  expiry_date INTEGER,
  notes TEXT,
  shopping_plan_id TEXT REFERENCES shopping_plans(id)
);

CREATE TABLE user_profiles (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  preferred_diet TEXT NOT NULL,
  daily_calorie_target INTEGER NOT NULL,
  height_cm REAL NOT NULL,
  weight_kg REAL NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  birth_date INTEGER,
  allergies TEXT NOT NULL DEFAULT '[]',
  disliked_ingredients TEXT NOT NULL DEFAULT '[]',
  photo_url TEXT
);

CREATE TABLE event_logs (
  id TEXT NOT NULL PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  metadata TEXT NOT NULL DEFAULT '{}',
  user_id TEXT REFERENCES user_profiles(id)
);

CREATE TABLE ingredients (
  id TEXT NOT NULL PRIMARY KEY,
  food_item_id TEXT NOT NULL REFERENCES food_items(id),
  quantity REAL NOT NULL,
  unit TEXT NOT NULL,
  preparation TEXT,
  recipe_id TEXT REFERENCES recipes(id),
  meal_entry_id TEXT REFERENCES meal_entries(id)
);
