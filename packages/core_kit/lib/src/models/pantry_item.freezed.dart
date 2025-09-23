// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PantryItem _$PantryItemFromJson(Map<String, dynamic> json) {
  return _PantryItem.fromJson(json);
}

/// @nodoc
mixin _$PantryItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  UnitType get unit => throw _privateConstructorUsedError;
  bool get isStaple => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PantryItemCopyWith<PantryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PantryItemCopyWith<$Res> {
  factory $PantryItemCopyWith(
          PantryItem value, $Res Function(PantryItem) then) =
      _$PantryItemCopyWithImpl<$Res, PantryItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      double quantity,
      UnitType unit,
      bool isStaple,
      DateTime? expiryDate,
      String? notes});
}

/// @nodoc
class _$PantryItemCopyWithImpl<$Res, $Val extends PantryItem>
    implements $PantryItemCopyWith<$Res> {
  _$PantryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? isStaple = null,
    Object? expiryDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as UnitType,
      isStaple: null == isStaple
          ? _value.isStaple
          : isStaple // ignore: cast_nullable_to_non_nullable
              as bool,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PantryItemImplCopyWith<$Res>
    implements $PantryItemCopyWith<$Res> {
  factory _$$PantryItemImplCopyWith(
          _$PantryItemImpl value, $Res Function(_$PantryItemImpl) then) =
      __$$PantryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double quantity,
      UnitType unit,
      bool isStaple,
      DateTime? expiryDate,
      String? notes});
}

/// @nodoc
class __$$PantryItemImplCopyWithImpl<$Res>
    extends _$PantryItemCopyWithImpl<$Res, _$PantryItemImpl>
    implements _$$PantryItemImplCopyWith<$Res> {
  __$$PantryItemImplCopyWithImpl(
      _$PantryItemImpl _value, $Res Function(_$PantryItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? isStaple = null,
    Object? expiryDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$PantryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as UnitType,
      isStaple: null == isStaple
          ? _value.isStaple
          : isStaple // ignore: cast_nullable_to_non_nullable
              as bool,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
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
class _$PantryItemImpl extends _PantryItem {
  const _$PantryItemImpl(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.unit,
      this.isStaple = false,
      this.expiryDate,
      this.notes})
      : super._();

  factory _$PantryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PantryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double quantity;
  @override
  final UnitType unit;
  @override
  @JsonKey()
  final bool isStaple;
  @override
  final DateTime? expiryDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PantryItem(id: $id, name: $name, quantity: $quantity, unit: $unit, isStaple: $isStaple, expiryDate: $expiryDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PantryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.isStaple, isStaple) ||
                other.isStaple == isStaple) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, quantity, unit, isStaple, expiryDate, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PantryItemImplCopyWith<_$PantryItemImpl> get copyWith =>
      __$$PantryItemImplCopyWithImpl<_$PantryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PantryItemImplToJson(
      this,
    );
  }
}

abstract class _PantryItem extends PantryItem {
  const factory _PantryItem(
      {required final String id,
      required final String name,
      required final double quantity,
      required final UnitType unit,
      final bool isStaple,
      final DateTime? expiryDate,
      final String? notes}) = _$PantryItemImpl;
  const _PantryItem._() : super._();

  factory _PantryItem.fromJson(Map<String, dynamic> json) =
      _$PantryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get quantity;
  @override
  UnitType get unit;
  @override
  bool get isStaple;
  @override
  DateTime? get expiryDate;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$PantryItemImplCopyWith<_$PantryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
