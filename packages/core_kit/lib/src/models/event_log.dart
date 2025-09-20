import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_utils.dart';

part 'event_log.freezed.dart';
part 'event_log.g.dart';

/// Auditable events captured throughout the application lifecycle.
@freezed
class EventLog with _$EventLog {
  const EventLog._();

  const factory EventLog({
    required String id,
    required DateTime timestamp,
    required String type,
    required String description,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    String? userId,
  }) = _EventLog;

  factory EventLog.create({
    String? id,
    required DateTime timestamp,
    required String type,
    required String description,
    Map<String, dynamic>? metadata,
    String? userId,
  }) =>
      EventLog(
        id: generateId(id),
        timestamp: timestamp,
        type: type,
        description: description,
        metadata: metadata ?? const <String, dynamic>{},
        userId: userId,
      );

  factory EventLog.fromJson(Map<String, dynamic> json) =>
      _$EventLogFromJson(json);
}
