import 'package:app_widgets/app_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppWidgetChannels', () {
    setUp(() {
      const MethodChannel(AppWidgetChannelsIds.widgetKit)
          .setMockMethodCallHandler(null);
      const MethodChannel(AppWidgetChannelsIds.homeWidget)
          .setMockMethodCallHandler(null);
    });

    test('parses meals returned by the WidgetKit channel', () async {
      const MethodChannel(AppWidgetChannelsIds.widgetKit)
          .setMockMethodCallHandler((MethodCall methodCall) async {
        expect(methodCall.method, 'getNextMeal');
        return <String, dynamic>{
          'id': 'from-native',
          'title': 'Cena leggera',
          'description': 'Mock da piattaforma',
          'scheduledAt': '2024-01-01T19:30:00.000Z',
          'items': <String>['Zuppa di verdure', 'Pane integrale'],
        };
      });

      final AppWidgetChannels channels = AppWidgetChannels();
      final WidgetMeal meal = await channels.fetchNextMealForWidgetKit();

      expect(meal.id, 'from-native');
      expect(meal.title, 'Cena leggera');
      expect(meal.description, 'Mock da piattaforma');
      expect(meal.items, <String>['Zuppa di verdure', 'Pane integrale']);
      expect(meal.scheduledAt, DateTime.parse('2024-01-01T19:30:00.000Z'));
    });

    test('falls back to mock meals when the plugin is missing', () async {
      final AppWidgetChannels channels = AppWidgetChannels(
        fallbackMealBuilder: (_) => WidgetMeal(
          id: 'fallback',
          title: 'Fallback',
          description: 'Nessun canale registrato',
          scheduledAt: DateTime.utc(2024, 1, 1, 12),
          items: const <String>['Acqua'],
        ),
      );

      final WidgetMeal meal = await channels.fetchNextMealForHomeWidget();

      expect(meal.id, 'fallback');
      expect(meal.items, <String>['Acqua']);
    });

    test('uses the fallback when the native channel returns null', () async {
      const MethodChannel(AppWidgetChannelsIds.homeWidget)
          .setMockMethodCallHandler((MethodCall methodCall) async {
        expect(methodCall.method, 'getNextMeal');
        return null;
      });

      final AppWidgetChannels channels = AppWidgetChannels(
        fallbackMealBuilder: (_) => WidgetMeal(
          id: 'null-fallback',
          title: 'Mock',
          scheduledAt: DateTime.utc(2024, 2, 2, 8),
        ),
      );

      final WidgetMeal meal = await channels.fetchNextMealForHomeWidget();

      expect(meal.id, 'null-fallback');
      expect(meal.title, 'Mock');
    });
  });
}
