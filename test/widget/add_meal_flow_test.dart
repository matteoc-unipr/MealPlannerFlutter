import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meals_feature/meals_feature.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('displays localized add meal options and triggers callbacks',
      (tester) async {
    var selection = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AddMealFlow(
            onScan: () => selection.add('scan'),
            onSearch: () => selection.add('search'),
            onRecipes: () => selection.add('recipes'),
            onQuickAdd: () => selection.add('quick'),
          ),
        ),
      ),
    );

    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Quick add'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick add'));
    await tester.pumpAndSettle();

    expect(selection, <String>['scan', 'search', 'recipes', 'quick']);
  });
}
