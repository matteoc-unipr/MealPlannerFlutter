// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PantryItemImpl _$$PantryItemImplFromJson(Map<String, dynamic> json) =>
    _$PantryItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: $enumDecode(_$UnitTypeEnumMap, json['unit']),
      isStaple: json['isStaple'] as bool? ?? false,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$PantryItemImplToJson(_$PantryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': _$UnitTypeEnumMap[instance.unit]!,
      'isStaple': instance.isStaple,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
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
