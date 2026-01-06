import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';


abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<void> saveProfile(UserProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const _key = 'profile';
  final SharedPreferences prefs;
  ProfileLocalDataSourceImpl(this.prefs);

  @override
  Future<UserProfileModel?> getProfile() async {
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return UserProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
