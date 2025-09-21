import 'package:core_kit/src/design/primary_button.dart';
import 'package:core_kit/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton renders provided label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: 'Continue',
              onPressed: () {},
              expanded: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
