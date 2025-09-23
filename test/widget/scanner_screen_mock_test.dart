import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:scanner_feature/scanner_screen.dart';

class _EmptyNutritionProvider extends CompositeNutritionProvider {
  _EmptyNutritionProvider()
      : super(
            providers: const <NutritionProvider>[],
            manualCatalog: const <String, FoodItem>{});

  @override
  Future<FoodItem?> lookupByBarcode(String barcode) async => null;
}

class _NoopMealRepository implements MealRepository {
  @override
  Future<void> addIngredient({
    required MealType mealType,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
  }) async {}
}

class _FakeStreamHandler extends StreamHandler<dynamic> {
  const _FakeStreamHandler();

  @override
  Future<void> onCancel(Object? arguments) async {}

  @override
  Future<void> onListen(Object? arguments, EventSink<dynamic> sink) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel =
      MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');
  const eventChannel =
      EventChannel('dev.steenbakker.mobile_scanner/scanner/event');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      if (call.method == 'start') {
        return <String, dynamic>{
          'numberOfCameras': 1,
          'hasTorch': false,
          'size': const <double>[0, 0],
        };
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, const _FakeStreamHandler());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  testWidgets('shows feedback when a scanned product is not found',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScannerScreen(
          mealRepository: _NoopMealRepository(),
          nutritionProvider: _EmptyNutritionProvider(),
          mobileScannerBuilder: (context, controller, onDetect) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  onDetect(
                    const BarcodeCapture(
                      barcodes: <Barcode>[Barcode(rawValue: '0000000000000')],
                    ),
                  );
                },
                child: const Text('Trigger scan'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Trigger scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
        find.text('Product not found. Try a different code.'), findsOneWidget);
  });
}
