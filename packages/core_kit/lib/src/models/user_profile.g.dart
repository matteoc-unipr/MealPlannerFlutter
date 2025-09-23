// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      preferredDiet: $enumDecode(_$DietModelEnumMap, json['preferredDiet']),
      shoppingDay: $enumDecode(_$WeekdayEnumMap, json['shoppingDay']),
      dailyCalorieTarget: (json['dailyCalorieTarget'] as num).toInt(),
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      dislikedIngredients: (json['dislikedIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'preferredDiet': _$DietModelEnumMap[instance.preferredDiet]!,
      'shoppingDay': _$WeekdayEnumMap[instance.shoppingDay]!,
      'dailyCalorieTarget': instance.dailyCalorieTarget,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'birthDate': instance.birthDate?.toIso8601String(),
      'allergies': instance.allergies,
      'dislikedIngredients': instance.dislikedIngredients,
      'photoUrl': instance.photoUrl,
    };

const _$DietModelEnumMap = {
  DietModel.omnivore: 'omnivore',
  DietModel.vegetarian: 'vegetarian',
  DietModel.vegan: 'vegan',
  DietModel.pescetarian: 'pescetarian',
  DietModel.keto: 'keto',
  DietModel.paleo: 'paleo',
  DietModel.mediterranean: 'mediterranean',
  DietModel.glutenFree: 'glutenFree',
};

const _$WeekdayEnumMap = {
  Weekday.monday: 'monday',
  Weekday.tuesday: 'tuesday',
  Weekday.wednesday: 'wednesday',
  Weekday.thursday: 'thursday',
  Weekday.friday: 'friday',
  Weekday.saturday: 'saturday',
  Weekday.sunday: 'sunday',
};
