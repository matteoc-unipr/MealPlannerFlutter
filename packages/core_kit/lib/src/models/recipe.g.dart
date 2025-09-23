// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      nutrients: Nutrients.fromJson(json['nutrients'] as Map<String, dynamic>),
      servingSize: (json['servingSize'] as num).toDouble(),
      servingUnit: $enumDecode(_$UnitTypeEnumMap, json['servingUnit']),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Ingredient>[],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'nutrients': instance.nutrients,
      'servingSize': instance.servingSize,
      'servingUnit': _$UnitTypeEnumMap[instance.servingUnit]!,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'tags': instance.tags,
      'prepTimeMinutes': instance.prepTimeMinutes,
      'cookTimeMinutes': instance.cookTimeMinutes,
      'imageUrl': instance.imageUrl,
      'sourceUrl': instance.sourceUrl,
    };

const _$UnitTypeEnumMap = {
  UnitType.gram: 'gram',
  UnitType.milliliter: 'milliliter',
  UnitType.ounce: 'ounce',
  UnitType.pound: 'pound',
  UnitType.piece: 'piece',
  UnitType.cup: 'cup',
  UnitType.tablespoon: 'tablespoon',
  UnitType.teaspoon: 'teaspoon',
  UnitType.serving: 'serving',
};
