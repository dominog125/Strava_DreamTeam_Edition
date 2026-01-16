import 'dart:io';
import 'dart:typed_data';

import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);


  Future<void> uploadAvatar(File file);


  Future<Uint8List?> getAvatarBytes();


  Future<void> deleteAvatar();
}
