// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventLog _$EventLogFromJson(Map<String, dynamic> json) {
  return _EventLog.fromJson(json);
}

/// @nodoc
mixin _$EventLog {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventLogCopyWith<EventLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventLogCopyWith<$Res> {
  factory $EventLogCopyWith(EventLog value, $Res Function(EventLog) then) =
      _$EventLogCopyWithImpl<$Res, EventLog>;
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String type,
      String description,
      Map<String, dynamic> metadata,
      String? userId});
}

/// @nodoc
class _$EventLogCopyWithImpl<$Res, $Val extends EventLog>
    implements $EventLogCopyWith<$Res> {
  _$EventLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? type = null,
    Object? description = null,
    Object? metadata = null,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventLogImplCopyWith<$Res>
    implements $EventLogCopyWith<$Res> {
  factory _$$EventLogImplCopyWith(
          _$EventLogImpl value, $Res Function(_$EventLogImpl) then) =
      __$$EventLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String type,
      String description,
      Map<String, dynamic> metadata,
      String? userId});
}

/// @nodoc
class __$$EventLogImplCopyWithImpl<$Res>
    extends _$EventLogCopyWithImpl<$Res, _$EventLogImpl>
    implements _$$EventLogImplCopyWith<$Res> {
  __$$EventLogImplCopyWithImpl(
      _$EventLogImpl _value, $Res Function(_$EventLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? type = null,
    Object? description = null,
    Object? metadata = null,
    Object? userId = freezed,
  }) {
    return _then(_$EventLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventLogImpl extends _EventLog {
  const _$EventLogImpl(
      {required this.id,
      required this.timestamp,
      required this.type,
      required this.description,
      final Map<String, dynamic> metadata = const <String, dynamic>{},
      this.userId})
      : _metadata = metadata,
        super._();

  factory _$EventLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventLogImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime timestamp;
  @override
  final String type;
  @override
  final String description;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final String? userId;

  @override
  String toString() {
    return 'EventLog(id: $id, timestamp: $timestamp, type: $type, description: $description, metadata: $metadata, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, timestamp, type, description,
      const DeepCollectionEquality().hash(_metadata), userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventLogImplCopyWith<_$EventLogImpl> get copyWith =>
      __$$EventLogImplCopyWithImpl<_$EventLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventLogImplToJson(
      this,
    );
  }
}

abstract class _EventLog extends EventLog {
  const factory _EventLog(
      {required final String id,
      required final DateTime timestamp,
      required final String type,
      required final String description,
      final Map<String, dynamic> metadata,
      final String? userId}) = _$EventLogImpl;
  const _EventLog._() : super._();

  factory _EventLog.fromJson(Map<String, dynamic> json) =
      _$EventLogImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  String get type;
  @override
  String get description;
  @override
  Map<String, dynamic> get metadata;
  @override
  String? get userId;
  @override
  @JsonKey(ignore: true)
  _$$EventLogImplCopyWith<_$EventLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
