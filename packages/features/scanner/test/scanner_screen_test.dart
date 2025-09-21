import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutrition_kit/nutrition_kit.dart';
import 'package:scanner_feature/confirm_food_screen.dart';
import 'package:scanner_feature/scanner_screen.dart';

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

  testWidgets('scanning a barcode navigates to confirmation screen',
      (tester) async {
    final foodItem = FoodItem.create(
      name: 'Pane integrale',
      nutrients: const Nutrients(
        calories: 80,
        protein: 4,
        fat: 1,
        carbohydrates: 14,
      ),
      servingSize: 1,
      servingUnit: UnitType.serving,
    );

    final nutritionProvider = _TestCompositeNutritionProvider(foodItem);
    final mealRepository = _FakeMealRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: ScannerScreen(
          nutritionProvider: nutritionProvider,
          mealRepository: mealRepository,
          mealType: MealType.lunch,
          mobileScannerBuilder: (
            context,
            controller,
            onDetect,
          ) {
            return Center(
              child: ElevatedButton(
                key: const Key('fake-scanner'),
                onPressed: () {
                  onDetect(
                    BarcodeCapture(
                      barcodes: const <Barcode>[
                        Barcode(rawValue: '0123456789012'),
                      ],
                    ),
                  );
                },
                child: const Text('Scan'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('fake-scanner')));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmFoodScreen), findsOneWidget);
    expect(find.text('Pane integrale'), findsOneWidget);

    await tester.tap(find.text('Aggiungi al pasto'));
    await tester.pumpAndSettle();

    expect(mealRepository.addedMealType, MealType.lunch);
    expect(mealRepository.addedItem, equals(foodItem));
    expect(mealRepository.addedQuantity, greaterThan(0));
    expect(mealRepository.addedUnit, UnitType.serving);
  });
}

class _FakeMealRepository implements MealRepository {
  MealType? addedMealType;
  FoodItem? addedItem;
  double? addedQuantity;
  UnitType? addedUnit;

  @override
  Future<void> addIngredient({
    required MealType mealType,
    required FoodItem item,
    required double quantity,
    required UnitType unit,
  }) async {
    addedMealType = mealType;
    addedItem = item;
    addedQuantity = quantity;
    addedUnit = unit;
  }
}

class _TestCompositeNutritionProvider extends CompositeNutritionProvider {
  _TestCompositeNutritionProvider(this._result)
      : super(
          providers: const <NutritionProvider>[],
          manualCatalog: const <String, FoodItem>{},
        );

  final FoodItem _result;

  @override
  Future<FoodItem?> lookupByBarcode(String barcode) async => _result;

  @override
  Future<List<FoodItem>> searchFoods(String query) async => <FoodItem>[];

  @override
  Future<Nutrients?> nutrientsFor(FoodItem item) async => item.nutrients;
}

class _FakeStreamHandler extends StreamHandler<dynamic> {
  const _FakeStreamHandler();

  @override
  Future<void> onCancel(Object? arguments) async {}

  @override
  Future<void> onListen(Object? arguments, EventSink<dynamic> sink) async {}
}
