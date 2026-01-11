import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static const _loggedInKey = 'is_logged_in';

  final SharedPreferences prefs;
  AuthSession(this.prefs);

  bool get isLoggedIn => prefs.getBool(_loggedInKey) ?? false;

  Future<void> login() async {
    await prefs.setBool(_loggedInKey, true);
  }

  Future<void> logout() async {
    await prefs.remove(_loggedInKey);
  }
}
