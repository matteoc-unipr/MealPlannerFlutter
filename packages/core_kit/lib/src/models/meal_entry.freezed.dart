// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MealEntry _$MealEntryFromJson(Map<String, dynamic> json) {
  return _MealEntry.fromJson(json);
}

/// @nodoc
mixin _$MealEntry {
  String get id => throw _privateConstructorUsedError;
  MealType get mealType => throw _privateConstructorUsedError;
  DateTime get consumedAt => throw _privateConstructorUsedError;
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  String? get recipeId => throw _privateConstructorUsedError;
  double? get servings => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MealEntryCopyWith<MealEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealEntryCopyWith<$Res> {
  factory $MealEntryCopyWith(MealEntry value, $Res Function(MealEntry) then) =
      _$MealEntryCopyWithImpl<$Res, MealEntry>;
  @useResult
  $Res call(
      {String id,
      MealType mealType,
      DateTime consumedAt,
      List<Ingredient> ingredients,
      String? recipeId,
      double? servings,
      String? notes});
}

/// @nodoc
class _$MealEntryCopyWithImpl<$Res, $Val extends MealEntry>
    implements $MealEntryCopyWith<$Res> {
  _$MealEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mealType = null,
    Object? consumedAt = null,
    Object? ingredients = null,
    Object? recipeId = freezed,
    Object? servings = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      consumedAt: null == consumedAt
          ? _value.consumedAt
          : consumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      recipeId: freezed == recipeId
          ? _value.recipeId
          : recipeId // ignore: cast_nullable_to_non_nullable
              as String?,
      servings: freezed == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealEntryImplCopyWith<$Res>
    implements $MealEntryCopyWith<$Res> {
  factory _$$MealEntryImplCopyWith(
          _$MealEntryImpl value, $Res Function(_$MealEntryImpl) then) =
      __$$MealEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MealType mealType,
      DateTime consumedAt,
      List<Ingredient> ingredients,
      String? recipeId,
      double? servings,
      String? notes});
}

/// @nodoc
class __$$MealEntryImplCopyWithImpl<$Res>
    extends _$MealEntryCopyWithImpl<$Res, _$MealEntryImpl>
    implements _$$MealEntryImplCopyWith<$Res> {
  __$$MealEntryImplCopyWithImpl(
      _$MealEntryImpl _value, $Res Function(_$MealEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mealType = null,
    Object? consumedAt = null,
    Object? ingredients = null,
    Object? recipeId = freezed,
    Object? servings = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$MealEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      consumedAt: null == consumedAt
          ? _value.consumedAt
          : consumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      recipeId: freezed == recipeId
          ? _value.recipeId
          : recipeId // ignore: cast_nullable_to_non_nullable
              as String?,
      servings: freezed == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealEntryImpl extends _MealEntry {
  const _$MealEntryImpl(
      {required this.id,
      required this.mealType,
      required this.consumedAt,
      final List<Ingredient> ingredients = const <Ingredient>[],
      this.recipeId,
      this.servings,
      this.notes})
      : _ingredients = ingredients,
        super._();

  factory _$MealEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealEntryImplFromJson(json);

  @override
  final String id;
  @override
  final MealType mealType;
  @override
  final DateTime consumedAt;
  final List<Ingredient> _ingredients;
  @override
  @JsonKey()
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  @override
  final String? recipeId;
  @override
  final double? servings;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MealEntry(id: $id, mealType: $mealType, consumedAt: $consumedAt, ingredients: $ingredients, recipeId: $recipeId, servings: $servings, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.consumedAt, consumedAt) ||
                other.consumedAt == consumedAt) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mealType,
      consumedAt,
      const DeepCollectionEquality().hash(_ingredients),
      recipeId,
      servings,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MealEntryImplCopyWith<_$MealEntryImpl> get copyWith =>
      __$$MealEntryImplCopyWithImpl<_$MealEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealEntryImplToJson(
      this,
    );
  }
}

abstract class _MealEntry extends MealEntry {
  const factory _MealEntry(
      {required final String id,
      required final MealType mealType,
      required final DateTime consumedAt,
      final List<Ingredient> ingredients,
      final String? recipeId,
      final double? servings,
      final String? notes}) = _$MealEntryImpl;
  const _MealEntry._() : super._();

  factory _MealEntry.fromJson(Map<String, dynamic> json) =
      _$MealEntryImpl.fromJson;

  @override
  String get id;
  @override
  MealType get mealType;
  @override
  DateTime get consumedAt;
  @override
  List<Ingredient> get ingredients;
  @override
  String? get recipeId;
  @override
  double? get servings;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$MealEntryImplCopyWith<_$MealEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
