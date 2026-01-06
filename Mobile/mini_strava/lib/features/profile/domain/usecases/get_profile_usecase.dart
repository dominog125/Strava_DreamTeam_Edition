import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repo;
  GetProfileUseCase(this.repo);

  Future<UserProfile?> call() => repo.getProfile();
}
