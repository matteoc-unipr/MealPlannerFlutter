abstract class AnalyticsClient {
  const AnalyticsClient();

  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  Future<void> setUserId(String? id);

  Future<void> setUserProperty(String name, String? value);
}

class NoopAnalyticsClient extends AnalyticsClient {
  const NoopAnalyticsClient();

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}
