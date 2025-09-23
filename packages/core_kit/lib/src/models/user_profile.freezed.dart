// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DietModel get preferredDiet => throw _privateConstructorUsedError;
  Weekday get shoppingDay => throw _privateConstructorUsedError;
  int get dailyCalorieTarget => throw _privateConstructorUsedError;
  double get heightCm => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get dislikedIngredients => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      DietModel preferredDiet,
      Weekday shoppingDay,
      int dailyCalorieTarget,
      double heightCm,
      double weightKg,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? birthDate,
      List<String> allergies,
      List<String> dislikedIngredients,
      String? photoUrl});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? preferredDiet = null,
    Object? shoppingDay = null,
    Object? dailyCalorieTarget = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? birthDate = freezed,
    Object? allergies = null,
    Object? dislikedIngredients = null,
    Object? photoUrl = freezed,
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
      preferredDiet: null == preferredDiet
          ? _value.preferredDiet
          : preferredDiet // ignore: cast_nullable_to_non_nullable
              as DietModel,
      shoppingDay: null == shoppingDay
          ? _value.shoppingDay
          : shoppingDay // ignore: cast_nullable_to_non_nullable
              as Weekday,
      dailyCalorieTarget: null == dailyCalorieTarget
          ? _value.dailyCalorieTarget
          : dailyCalorieTarget // ignore: cast_nullable_to_non_nullable
              as int,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allergies: null == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedIngredients: null == dislikedIngredients
          ? _value.dislikedIngredients
          : dislikedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DietModel preferredDiet,
      Weekday shoppingDay,
      int dailyCalorieTarget,
      double heightCm,
      double weightKg,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? birthDate,
      List<String> allergies,
      List<String> dislikedIngredients,
      String? photoUrl});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? preferredDiet = null,
    Object? shoppingDay = null,
    Object? dailyCalorieTarget = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? birthDate = freezed,
    Object? allergies = null,
    Object? dislikedIngredients = null,
    Object? photoUrl = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      preferredDiet: null == preferredDiet
          ? _value.preferredDiet
          : preferredDiet // ignore: cast_nullable_to_non_nullable
              as DietModel,
      shoppingDay: null == shoppingDay
          ? _value.shoppingDay
          : shoppingDay // ignore: cast_nullable_to_non_nullable
              as Weekday,
      dailyCalorieTarget: null == dailyCalorieTarget
          ? _value.dailyCalorieTarget
          : dailyCalorieTarget // ignore: cast_nullable_to_non_nullable
              as int,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allergies: null == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedIngredients: null == dislikedIngredients
          ? _value._dislikedIngredients
          : dislikedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl extends _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.name,
      required this.preferredDiet,
      required this.shoppingDay,
      required this.dailyCalorieTarget,
      required this.heightCm,
      required this.weightKg,
      required this.createdAt,
      required this.updatedAt,
      this.birthDate,
      final List<String> allergies = const <String>[],
      final List<String> dislikedIngredients = const <String>[],
      this.photoUrl})
      : _allergies = allergies,
        _dislikedIngredients = dislikedIngredients,
        super._();

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final DietModel preferredDiet;
  @override
  final Weekday shoppingDay;
  @override
  final int dailyCalorieTarget;
  @override
  final double heightCm;
  @override
  final double weightKg;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? birthDate;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _dislikedIngredients;
  @override
  @JsonKey()
  List<String> get dislikedIngredients {
    if (_dislikedIngredients is EqualUnmodifiableListView)
      return _dislikedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dislikedIngredients);
  }

  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, preferredDiet: $preferredDiet, shoppingDay: $shoppingDay, dailyCalorieTarget: $dailyCalorieTarget, heightCm: $heightCm, weightKg: $weightKg, createdAt: $createdAt, updatedAt: $updatedAt, birthDate: $birthDate, allergies: $allergies, dislikedIngredients: $dislikedIngredients, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.preferredDiet, preferredDiet) ||
                other.preferredDiet == preferredDiet) &&
            (identical(other.shoppingDay, shoppingDay) ||
                other.shoppingDay == shoppingDay) &&
            (identical(other.dailyCalorieTarget, dailyCalorieTarget) ||
                other.dailyCalorieTarget == dailyCalorieTarget) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            const DeepCollectionEquality()
                .equals(other._dislikedIngredients, _dislikedIngredients) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      preferredDiet,
      shoppingDay,
      dailyCalorieTarget,
      heightCm,
      weightKg,
      createdAt,
      updatedAt,
      birthDate,
      const DeepCollectionEquality().hash(_allergies),
      const DeepCollectionEquality().hash(_dislikedIngredients),
      photoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile extends UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String name,
      required final DietModel preferredDiet,
      required final Weekday shoppingDay,
      required final int dailyCalorieTarget,
      required final double heightCm,
      required final double weightKg,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? birthDate,
      final List<String> allergies,
      final List<String> dislikedIngredients,
      final String? photoUrl}) = _$UserProfileImpl;
  const _UserProfile._() : super._();

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  DietModel get preferredDiet;
  @override
  Weekday get shoppingDay;
  @override
  int get dailyCalorieTarget;
  @override
  double get heightCm;
  @override
  double get weightKg;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get birthDate;
  @override
  List<String> get allergies;
  @override
  List<String> get dislikedIngredients;
  @override
  String? get photoUrl;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
