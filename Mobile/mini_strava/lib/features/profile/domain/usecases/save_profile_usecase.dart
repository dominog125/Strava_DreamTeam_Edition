import 'dart:io';

import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository repo;
  SaveProfileUseCase(this.repo);

  Future<void> call(UserProfile profile) async {

    final local = (profile.avatarPathOrUrl ?? '').trim();
    if (local.isNotEmpty && !local.startsWith('http')) {
      final file = File(local);
      if (await file.exists()) {
        await repo.uploadAvatar(file); // void
      }
    }


    final updatedProfile = profile.copyWith(avatarPathOrUrl: null);
    await repo.saveProfile(updatedProfile);
  }
}
