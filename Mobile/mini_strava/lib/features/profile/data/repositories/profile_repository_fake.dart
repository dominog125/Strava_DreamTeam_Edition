import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryFake implements ProfileRepository {
  UserProfile? _cached;

  @override
  Future<UserProfile?> getProfile() async {
    // symulacja IO
    await Future.delayed(const Duration(milliseconds: 150));
    return _cached;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _cached = profile;
  }
}
