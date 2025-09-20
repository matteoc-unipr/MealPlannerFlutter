import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrients.freezed.dart';
part 'nutrients.g.dart';

/// Macro and micro nutrient data for food entities.
@freezed
class Nutrients with _$Nutrients {
  const factory Nutrients({
    @Default(0.0) double calories,
    @Default(0.0) double protein,
    @Default(0.0) double fat,
    @Default(0.0) double carbohydrates,
    @Default(0.0) double fiber,
    @Default(0.0) double sugar,
    @Default(0.0) double sodium,
  }) = _Nutrients;

  factory Nutrients.fromJson(Map<String, dynamic> json) =>
      _$NutrientsFromJson(json);
}
