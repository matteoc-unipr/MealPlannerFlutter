import 'dart:convert';
import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:core_kit/src/drift/drift_database.dart';
import 'package:data_kit/data_kit.dart' as data_kit;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_feature/settings_feature.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late data_kit.FoodItemDao foodItemDao;

  setUp(() async {
    database = await data_kit.initDatabase(
      executor: NativeDatabase.memory(),
      reset: true,
    );
    foodItemDao = data_kit.FoodItemDao(database);
  });

  tearDown(() async {
    await data_kit.closeDatabase();
  });

  testWidgets('export button generates JSON snapshot', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('settings_export_test');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final exportPath = '${tempDir.path}/export.json';

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(exportPath: exportPath),
      ),
    );

    await tester.tap(find.byKey(const Key('settings_export_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final file = File(exportPath);
    expect(file.existsSync(), isTrue);

    final dynamic content = jsonDecode(await file.readAsString());
    expect(content, isA<Map<String, dynamic>>());
    expect(content['foodItems'], isA<List<dynamic>>());
    expect(content['mealEntries'], isA<List<dynamic>>());
    expect(content['userProfiles'], isA<List<dynamic>>());
    expect(content['shoppingPlans'], isA<List<dynamic>>());
  });

  testWidgets('delete button clears the database after confirmation', (tester) async {
    final food = FoodItem.create(
      name: 'Mela',
      nutrients: const Nutrients(calories: 52, protein: 1.0, fat: 0.2, carbohydrates: 14.0),
      servingSize: 100,
      servingUnit: UnitType.gram,
    );
    await foodItemDao.upsertFoodItem(food);

    final storedBefore = await foodItemDao.getAllFoodItems();
    expect(storedBefore, isNotEmpty);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('settings_delete_button')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('settings_confirm_delete_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final storedAfter = await foodItemDao.getAllFoodItems();
    expect(storedAfter, isEmpty);
  });
}
