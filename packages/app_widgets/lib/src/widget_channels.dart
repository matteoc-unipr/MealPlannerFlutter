import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'widget_meal.dart';

typedef WidgetMealBuilder = WidgetMeal Function(DateTime now);

/// Coordinates the Dart side of the platform channels used to communicate
/// with iOS WidgetKit and Android HomeWidget implementations.
@immutable
class AppWidgetChannels {
  AppWidgetChannels({
    BinaryMessenger? binaryMessenger,
    WidgetMealBuilder? fallbackMealBuilder,
  })  : _widgetKitChannel = MethodChannel(
          _widgetKitChannelName,
          const StandardMethodCodec(),
          binaryMessenger,
        ),
        _homeWidgetChannel = MethodChannel(
          _homeWidgetChannelName,
          const StandardMethodCodec(),
          binaryMessenger,
        ),
        _fallbackMealBuilder =
            fallbackMealBuilder ?? ((DateTime now) => WidgetMeal.mock(now: now));

  static const String _widgetKitChannelName = 'app_widgets/widgetkit';
  static const String _homeWidgetChannelName = 'app_widgets/homewidget';
  static const String _methodGetNextMeal = 'getNextMeal';

  final MethodChannel _widgetKitChannel;
  final MethodChannel _homeWidgetChannel;
  final WidgetMealBuilder _fallbackMealBuilder;

  /// Returns the next meal that should be rendered inside the iOS WidgetKit
  /// extension. If no native implementation is available a mock meal is
  /// returned to keep widgets functional during development.
  Future<WidgetMeal> fetchNextMealForWidgetKit() async {
    return _fetchNextMeal(_widgetKitChannel);
  }

  /// Returns the next meal that should be rendered inside the Android
  /// HomeWidget extension. If no native implementation is available a mock meal
  /// is returned to keep widgets functional during development.
  Future<WidgetMeal> fetchNextMealForHomeWidget() async {
    return _fetchNextMeal(_homeWidgetChannel);
  }

  Future<WidgetMeal> _fetchNextMeal(MethodChannel channel) async {
    try {
      final Map<String, dynamic>? response =
          await channel.invokeMapMethod<String, dynamic>(_methodGetNextMeal);
      if (response != null && response.isNotEmpty) {
        return WidgetMeal.fromMap(response);
      }
    } on MissingPluginException {
      // Fall back to the mock implementation when the native side is missing.
    } on PlatformException {
      // Errors are swallowed so widgets remain usable in development builds.
    }

    return _fallbackMealBuilder(DateTime.now());
  }
}

/// Provides access to the default channel names in case other packages need
/// to interact with them for testing purposes.
class AppWidgetChannelsIds {
  const AppWidgetChannelsIds._();

  static const String widgetKit = AppWidgetChannels._widgetKitChannelName;
  static const String homeWidget = AppWidgetChannels._homeWidgetChannelName;
}
