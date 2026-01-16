import 'dart:io';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repo;
  UploadAvatarUseCase(this.repo);

  Future<void> call(File file) => repo.uploadAvatar(file);
}
