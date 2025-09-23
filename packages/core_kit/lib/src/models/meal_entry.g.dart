// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealEntryImpl _$$MealEntryImplFromJson(Map<String, dynamic> json) =>
    _$MealEntryImpl(
      id: json['id'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Ingredient>[],
      recipeId: json['recipeId'] as String?,
      servings: (json['servings'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MealEntryImplToJson(_$MealEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'consumedAt': instance.consumedAt.toIso8601String(),
      'ingredients': instance.ingredients,
      'recipeId': instance.recipeId,
      'servings': instance.servings,
      'notes': instance.notes,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
