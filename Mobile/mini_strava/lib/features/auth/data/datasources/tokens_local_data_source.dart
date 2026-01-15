import 'package:shared_preferences/shared_preferences.dart';

class TokensLocalDataSource {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAccess, accessToken);
    await sp.setString(_kRefresh, refreshToken);
  }

  Future<Map<String, String>?> read() async {
    final sp = await SharedPreferences.getInstance();
    final a = sp.getString(_kAccess);
    final r = sp.getString(_kRefresh);
    if (a == null || r == null) return null;
    return {'accessToken': a, 'refreshToken': r};
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
    await sp.remove(_kRefresh);
  }
}
