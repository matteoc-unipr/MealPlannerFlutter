// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventLogImpl _$$EventLogImplFromJson(Map<String, dynamic> json) =>
    _$EventLogImpl(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$EventLogImplToJson(_$EventLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': instance.type,
      'description': instance.description,
      'metadata': instance.metadata,
      'userId': instance.userId,
    };
