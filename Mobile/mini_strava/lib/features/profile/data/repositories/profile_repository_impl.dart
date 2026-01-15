import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  final ProfileRemoteDataSource remote;
  final NetworkInfo network;

  ProfileRepositoryImpl(this.local, this.remote, this.network);

  String _genderToApi(Gender g) {
    switch (g) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
      case Gender.notSet:
        return 'notSet';
    }
  }

  @override
  Future<UserProfile?> getProfile() async {
    final cached = await local.getProfile(); // UserProfileModel?
    final cachedAvatar = (cached?.avatarPathOrUrl ?? '').trim();

    if (await network.isConnected) {
      try {
        final json = await remote.getMe();
        final api = UserProfileModel.fromJson(json);


        final merged = UserProfileModel(
          firstName: api.firstName,
          lastName: api.lastName,
          birthDate: api.birthDate,
          gender: api.gender,
          heightCm: api.heightCm ?? 0,
          weightKg: api.weightKg ?? 0.0,
          avatarPathOrUrl: cachedAvatar.isEmpty ? null : cachedAvatar,
        );

        await local.saveProfile(merged);
        return merged;
      } catch (_) {
        return cached;
      }
    }

    return cached;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {

    final model = UserProfileModel(
      firstName: profile.firstName,
      lastName: profile.lastName,
      birthDate: profile.birthDate,
      gender: profile.gender,
      heightCm: profile.heightCm ?? 0,
      weightKg: profile.weightKg ?? 0.0,
      avatarPathOrUrl: (profile.avatarPathOrUrl ?? '').trim().isEmpty
          ? null
          : profile.avatarPathOrUrl,
    );

    await local.saveProfile(model);


    if (await network.isConnected) {
      await remote.updateMe(
        firstName: model.firstName,
        lastName: model.lastName,
        birthDate: model.birthDate,
        gender: _genderToApi(model.gender),
        heightCm: model.heightCm ?? 0,
        weightKg: model.weightKg ?? 0.0,
      );
    }
  }
}
