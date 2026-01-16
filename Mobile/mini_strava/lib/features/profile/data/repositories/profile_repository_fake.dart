import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryFake implements ProfileRepository {
  UserProfile? _cached;
  Uint8List? _avatarBytes;

  @override
  Future<UserProfile?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _cached;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _cached = profile;
  }

  @override
  Future<void> uploadAvatar(File file) async {

    await Future.delayed(const Duration(milliseconds: 200));
    _avatarBytes = Uint8List.fromList([0, 0, 0, 0]);
  }

  @override
  Future<Uint8List?> getAvatarBytes() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _avatarBytes;
  }

  @override
  Future<void> deleteAvatar() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _avatarBytes = null;

    if (_cached == null) return;
    _cached = _cached!.copyWith(avatarPathOrUrl: null);
  }
}
