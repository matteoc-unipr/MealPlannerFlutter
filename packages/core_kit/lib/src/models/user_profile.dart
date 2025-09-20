import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'model_utils.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Describes personalized settings and targets for a user.
@freezed
class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String id,
    required String name,
    required DietModel preferredDiet,
    required int dailyCalorieTarget,
    required double heightCm,
    required double weightKg,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? birthDate,
    @Default(<String>[]) List<String> allergies,
    @Default(<String>[]) List<String> dislikedIngredients,
    String? photoUrl,
  }) = _UserProfile;

  factory UserProfile.create({
    String? id,
    required String name,
    required DietModel preferredDiet,
    required int dailyCalorieTarget,
    required double heightCm,
    required double weightKg,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? birthDate,
    List<String>? allergies,
    List<String>? dislikedIngredients,
    String? photoUrl,
  }) =>
      UserProfile(
        id: generateId(id),
        name: name,
        preferredDiet: preferredDiet,
        dailyCalorieTarget: dailyCalorieTarget,
        heightCm: heightCm,
        weightKg: weightKg,
        createdAt: createdAt,
        updatedAt: updatedAt,
        birthDate: birthDate,
        allergies: allergies ?? const <String>[],
        dislikedIngredients: dislikedIngredients ?? const <String>[],
        photoUrl: photoUrl,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
