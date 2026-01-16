import '../repositories/profile_repository.dart';

class DeleteAvatarUseCase {
  final ProfileRepository repo;
  DeleteAvatarUseCase(this.repo);

  Future<void> call() => repo.deleteAvatar();
}