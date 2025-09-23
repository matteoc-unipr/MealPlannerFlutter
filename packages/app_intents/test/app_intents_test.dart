import 'package:app_intents/app_intents.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIntent', () {
    test('serializes AddMealIntent to a map', () {
      const AddMealIntent intent = AddMealIntent();

      final Map<String, dynamic> serialized = intent.toMap();

      expect(serialized['id'], 'add_meal');
      expect(serialized['name'], 'Aggiungi pasto');
      expect(serialized['deepLink'], 'assistente://meals/add');
      expect(serialized['keywords'], contains('pasto'));
    });

    test('generates Android shortcut metadata', () {
      const SuggestLunchIntent intent = SuggestLunchIntent();

      final Map<String, dynamic> shortcut = intent.toAndroidShortcut(
        shortLabel: 'Pranzo',
        iconName: 'ic_shortcut_lunch',
        rank: 1,
      );

      expect(shortcut['id'], intent.id);
      expect(shortcut['shortLabel'], 'Pranzo');
      expect(shortcut['longLabel'], intent.description);
      expect(shortcut['uri'], intent.deepLink.toString());
      expect(shortcut['intentAction'], 'android.intent.action.VIEW');
      expect(shortcut['icon'], 'ic_shortcut_lunch');
      expect(shortcut['rank'], 1);
      expect(shortcut['categories'], contains('assistente.intent.shortcut'));
    });
  });

  group('AppIntentController', () {
    setUp(() {
      const MethodChannel(AppIntentChannelIds.intents)
          .setMockMethodCallHandler(null);
    });

    test('invokes the method channel with the correct payload', () async {
      final List<MethodCall> calls = <MethodCall>[];
      const MethodChannel(AppIntentChannelIds.intents)
          .setMockMethodCallHandler((MethodCall call) async {
        calls.add(call);
        return true;
      });

      final AppIntentController controller = AppIntentController();
      await controller.trigger(const SuggestLunchIntent());

      expect(calls, hasLength(1));
      expect(calls.first.method, 'triggerIntent');
      expect(calls.first.arguments, isA<Map<String, dynamic>>());
      final Map<Object?, Object?> arguments =
          calls.first.arguments as Map<Object?, Object?>;
      expect(arguments['id'], 'suggest_lunch');
      expect(arguments['deepLink'], 'assistente://suggestions/lunch');
    });

    test('delegates to the fallback when the plugin is missing', () async {
      final List<AppIntent> fallbackInvocations = <AppIntent>[];

      final AppIntentController controller = AppIntentController(
        onFallback: (AppIntent intent) async {
          fallbackInvocations.add(intent);
        },
      );

      await controller.trigger(const AddMealIntent());

      expect(fallbackInvocations, hasLength(1));
      expect(fallbackInvocations.single.id, 'add_meal');
    });
  });
}
