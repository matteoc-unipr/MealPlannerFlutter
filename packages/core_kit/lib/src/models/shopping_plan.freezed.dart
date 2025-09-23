// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShoppingPlan _$ShoppingPlanFromJson(Map<String, dynamic> json) {
  return _ShoppingPlan.fromJson(json);
}

/// @nodoc
mixin _$ShoppingPlan {
  String get id => throw _privateConstructorUsedError;
  Weekday get weekStart => throw _privateConstructorUsedError;
  PlanStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<PantryItem> get items => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShoppingPlanCopyWith<ShoppingPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingPlanCopyWith<$Res> {
  factory $ShoppingPlanCopyWith(
          ShoppingPlan value, $Res Function(ShoppingPlan) then) =
      _$ShoppingPlanCopyWithImpl<$Res, ShoppingPlan>;
  @useResult
  $Res call(
      {String id,
      Weekday weekStart,
      PlanStatus status,
      DateTime createdAt,
      List<PantryItem> items,
      DateTime? updatedAt,
      DateTime? completedAt,
      String? notes});
}

/// @nodoc
class _$ShoppingPlanCopyWithImpl<$Res, $Val extends ShoppingPlan>
    implements $ShoppingPlanCopyWith<$Res> {
  _$ShoppingPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? weekStart = null,
    Object? status = null,
    Object? createdAt = null,
    Object? items = null,
    Object? updatedAt = freezed,
    Object? completedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as Weekday,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PlanStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PantryItem>,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShoppingPlanImplCopyWith<$Res>
    implements $ShoppingPlanCopyWith<$Res> {
  factory _$$ShoppingPlanImplCopyWith(
          _$ShoppingPlanImpl value, $Res Function(_$ShoppingPlanImpl) then) =
      __$$ShoppingPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Weekday weekStart,
      PlanStatus status,
      DateTime createdAt,
      List<PantryItem> items,
      DateTime? updatedAt,
      DateTime? completedAt,
      String? notes});
}

/// @nodoc
class __$$ShoppingPlanImplCopyWithImpl<$Res>
    extends _$ShoppingPlanCopyWithImpl<$Res, _$ShoppingPlanImpl>
    implements _$$ShoppingPlanImplCopyWith<$Res> {
  __$$ShoppingPlanImplCopyWithImpl(
      _$ShoppingPlanImpl _value, $Res Function(_$ShoppingPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? weekStart = null,
    Object? status = null,
    Object? createdAt = null,
    Object? items = null,
    Object? updatedAt = freezed,
    Object? completedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ShoppingPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as Weekday,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PlanStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PantryItem>,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShoppingPlanImpl extends _ShoppingPlan {
  const _$ShoppingPlanImpl(
      {required this.id,
      required this.weekStart,
      required this.status,
      required this.createdAt,
      final List<PantryItem> items = const <PantryItem>[],
      this.updatedAt,
      this.completedAt,
      this.notes})
      : _items = items,
        super._();

  factory _$ShoppingPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShoppingPlanImplFromJson(json);

  @override
  final String id;
  @override
  final Weekday weekStart;
  @override
  final PlanStatus status;
  @override
  final DateTime createdAt;
  final List<PantryItem> _items;
  @override
  @JsonKey()
  List<PantryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime? updatedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ShoppingPlan(id: $id, weekStart: $weekStart, status: $status, createdAt: $createdAt, items: $items, updatedAt: $updatedAt, completedAt: $completedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      weekStart,
      status,
      createdAt,
      const DeepCollectionEquality().hash(_items),
      updatedAt,
      completedAt,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingPlanImplCopyWith<_$ShoppingPlanImpl> get copyWith =>
      __$$ShoppingPlanImplCopyWithImpl<_$ShoppingPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShoppingPlanImplToJson(
      this,
    );
  }
}

abstract class _ShoppingPlan extends ShoppingPlan {
  const factory _ShoppingPlan(
      {required final String id,
      required final Weekday weekStart,
      required final PlanStatus status,
      required final DateTime createdAt,
      final List<PantryItem> items,
      final DateTime? updatedAt,
      final DateTime? completedAt,
      final String? notes}) = _$ShoppingPlanImpl;
  const _ShoppingPlan._() : super._();

  factory _ShoppingPlan.fromJson(Map<String, dynamic> json) =
      _$ShoppingPlanImpl.fromJson;

  @override
  String get id;
  @override
  Weekday get weekStart;
  @override
  PlanStatus get status;
  @override
  DateTime get createdAt;
  @override
  List<PantryItem> get items;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ShoppingPlanImplCopyWith<_$ShoppingPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
