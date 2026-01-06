import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository repo;
  SaveProfileUseCase(this.repo);

  Future<void> call(UserProfile profile) => repo.saveProfile(profile);
}
