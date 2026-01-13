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

    final birthRaw = json['birthDate'] as String?;
    final birthDate = (birthRaw == null || birthRaw.trim().isEmpty)
        ? null
        : DateTime.tryParse(birthRaw);

    return UserProfileModel(
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      birthDate: birthDate,
      gender: gender,
      heightCm: (json['heightCm'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,

      avatarPathOrUrl: (json['avatarPathOrUrl'] as String?)?.trim().isEmpty == true
          ? null
          : json['avatarPathOrUrl'] as String?,
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
      'birthDate': birthDate?.toIso8601String(),
      'gender': genderStr,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'avatarPathOrUrl': avatarPathOrUrl,
    };
  }
}
