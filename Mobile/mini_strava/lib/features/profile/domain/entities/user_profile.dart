enum Gender { male, female, other, notSet }

class UserProfile {
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final Gender gender;
  final int? heightCm;
  final double? weightKg;


  final String? avatarPathOrUrl;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.avatarPathOrUrl,
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    Gender? gender,
    int? heightCm,
    double? weightKg,
    String? avatarPathOrUrl,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      avatarPathOrUrl: avatarPathOrUrl ?? this.avatarPathOrUrl,
    );
  }
}
