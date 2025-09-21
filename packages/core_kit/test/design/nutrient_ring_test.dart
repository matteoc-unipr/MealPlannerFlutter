import 'package:core_kit/src/design/nutrient_ring.dart';
import 'package:core_kit/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NutrientRing paints an arc for the current progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: NutrientRing(
              value: 60,
              goal: 100,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ringFinder = find.byType(NutrientRing);
    expect(ringFinder, findsOneWidget);
    expect(
      find.descendant(of: ringFinder, matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });
}
