import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'app_intent.dart';

typedef IntentFallback = Future<void> Function(AppIntent intent);

/// Handles triggering platform intents from the Dart side.
@immutable
class AppIntentController {
  AppIntentController({
    BinaryMessenger? binaryMessenger,
    IntentFallback? onFallback,
  })  : _channel = MethodChannel(
          _intentChannelName,
          const StandardMethodCodec(),
          binaryMessenger,
        ),
        _onFallback = onFallback ?? _defaultFallback;

  static const String _intentChannelName = 'app_intents/intents';
  static const String _triggerMethod = 'triggerIntent';

  final MethodChannel _channel;
  final IntentFallback _onFallback;

  /// Triggers the provided [intent], delegating the execution to the native
  /// platform. If no native implementation is available a fallback handler is
  /// executed instead, which is useful during development and in tests.
  Future<void> trigger(AppIntent intent) async {
    try {
      await _channel.invokeMethod<void>(_triggerMethod, intent.toMap());
    } on MissingPluginException {
      await _onFallback(intent);
    } on PlatformException {
      await _onFallback(intent);
    }
  }

  static Future<void> _defaultFallback(AppIntent intent) async {
    debugPrint(
      'Fallback trigger for intent ${intent.id} -> ${intent.deepLink}',
    );
  }
}

/// Exposes the method channel identifiers used by [AppIntentController],
/// making it simpler to register mock handlers in tests and in other packages.
class AppIntentChannelIds {
  const AppIntentChannelIds._();

  static const String intents = AppIntentController._intentChannelName;
}
