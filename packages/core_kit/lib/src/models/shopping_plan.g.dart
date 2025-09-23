// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShoppingPlanImpl _$$ShoppingPlanImplFromJson(Map<String, dynamic> json) =>
    _$ShoppingPlanImpl(
      id: json['id'] as String,
      weekStart: $enumDecode(_$WeekdayEnumMap, json['weekStart']),
      status: $enumDecode(_$PlanStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PantryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PantryItem>[],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ShoppingPlanImplToJson(_$ShoppingPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weekStart': _$WeekdayEnumMap[instance.weekStart]!,
      'status': _$PlanStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
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

const _$PlanStatusEnumMap = {
  PlanStatus.pending: 'pending',
  PlanStatus.active: 'active',
  PlanStatus.completed: 'completed',
  PlanStatus.cancelled: 'cancelled',
};
