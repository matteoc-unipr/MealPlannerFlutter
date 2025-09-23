import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meals_feature/meals_feature.dart';

void main() {
  testWidgets('renders the four add meal options and triggers callbacks',
      (tester) async {
    var selection = '';

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AddMealFlow(
            onScan: () => selection = 'scan',
            onSearch: () => selection = 'search',
            onRecipes: () => selection = 'recipes',
            onQuickAdd: () => selection = 'quick',
            title: 'Aggiungi pasto',
            subtitle: 'Scegli come vuoi registrare il tuo pasto.',
          ),
        ),
      ),
    );

    expect(find.text('Scansiona'), findsOneWidget);
    expect(find.text('Cerca'), findsOneWidget);
    expect(find.text('Ricette'), findsOneWidget);
    expect(find.text('Rapidi'), findsOneWidget);

    await tester.tap(find.text('Scansiona'));
    await tester.pumpAndSettle();
    expect(selection, 'scan');

    await tester.tap(find.text('Cerca'));
    await tester.pumpAndSettle();
    expect(selection, 'search');

    await tester.tap(find.text('Ricette'));
    await tester.pumpAndSettle();
    expect(selection, 'recipes');

    await tester.tap(find.text('Rapidi'));
    await tester.pumpAndSettle();
    expect(selection, 'quick');
  });
}
