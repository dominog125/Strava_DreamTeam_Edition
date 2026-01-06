import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  final NetworkInfo network;

  ProfileRepositoryImpl(this.local, this.network);

  @override
  Future<UserProfile?> getProfile() async {

    return local.getProfile();
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {

    final model = UserProfileModel(
      firstName: profile.firstName,
      lastName: profile.lastName,
      birthDate: profile.birthDate,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      avatarPathOrUrl: profile.avatarPathOrUrl,
    );
    await local.saveProfile(model);

    // TODO(API): jeśli jest internet -> wyślij na serwer
    // if (await network.isConnected) { remote.saveProfile(model); }
  }
}
