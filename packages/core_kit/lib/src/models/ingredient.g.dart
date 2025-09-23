// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientImpl _$$IngredientImplFromJson(Map<String, dynamic> json) =>
    _$IngredientImpl(
      id: json['id'] as String,
      item: FoodItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      unit: $enumDecode(_$UnitTypeEnumMap, json['unit']),
      preparation: json['preparation'] as String?,
    );

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item': instance.item,
      'quantity': instance.quantity,
      'unit': _$UnitTypeEnumMap[instance.unit]!,
      'preparation': instance.preparation,
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
