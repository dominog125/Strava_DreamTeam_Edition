import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required super.gender,
    required super.heightCm,
    required super.weightKg,
    super.avatarPathOrUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final genderStr = (json['gender'] as String?) ?? 'notSet';
    final gender = switch (genderStr) {
      'male' => Gender.male,
      'female' => Gender.female,
      'other' => Gender.other,
      _ => Gender.notSet,
    };

    return UserProfileModel(
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: gender,
      heightCm: (json['heightCm'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      avatarPathOrUrl: json['avatarPathOrUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final genderStr = switch (gender) {
      Gender.male => 'male',
      Gender.female => 'female',
      Gender.other => 'other',
      Gender.notSet => 'notSet',
    };

    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'gender': genderStr,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'avatarPathOrUrl': avatarPathOrUrl,
    };
  }
}
