// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodItemImpl _$$FoodItemImplFromJson(Map<String, dynamic> json) =>
    _$FoodItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nutrients: Nutrients.fromJson(json['nutrients'] as Map<String, dynamic>),
      servingSize: (json['servingSize'] as num).toDouble(),
      servingUnit: $enumDecode(_$UnitTypeEnumMap, json['servingUnit']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$FoodItemImplToJson(_$FoodItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nutrients': instance.nutrients,
      'servingSize': instance.servingSize,
      'servingUnit': _$UnitTypeEnumMap[instance.servingUnit]!,
      'tags': instance.tags,
      'allergens': instance.allergens,
      'brand': instance.brand,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
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
