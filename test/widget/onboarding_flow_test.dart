import 'dart:io';

import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:settings_feature/settings_feature.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('collects onboarding preferences and handles actions',
      (tester) async {
    var exportCalled = false;
    var eraseCalled = false;
    final exportFile = File('test_export.json');
    addTearDown(() async {
      if (await exportFile.exists()) {
        await exportFile.delete();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsScreen(
            exportJson: () async {
              exportCalled = true;
              return <String, dynamic>{'profiles': 1};
            },
            eraseAll: () async {
              eraseCalled = true;
            },
            exportPath: exportFile.path,
            initialKcalTarget: 0,
            initialMacroTargets: const Nutrients(),
          ),
        ),
      ),
    );

    await tester.enterText(
        find.byKey(const Key('settings_kcal_field')), '1800');
    await tester.enterText(
        find.byKey(const Key('settings_protein_field')), '120');
    await tester.enterText(
        find.byKey(const Key('settings_carbs_field')), '200');
    await tester.enterText(find.byKey(const Key('settings_fat_field')), '70');
    await tester.enterText(
        find.byKey(const Key('settings_allergies_field')), 'peanuts, celery');

    await tester.tap(find.byKey(const Key('settings_shopping_day_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friday').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_health_toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_export_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(exportCalled, isTrue);
    expect(find.text('Export completed.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings_delete_button')));
    await tester.pumpAndSettle();

    expect(find.text('Delete data'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings_confirm_delete_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(eraseCalled, isTrue);
    expect(find.text('All data has been deleted.'), findsOneWidget);
  });
}
