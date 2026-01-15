import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';
  final SharedPreferences prefs;

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeController(this.prefs) {
    _mode = _readFromPrefs();
  }

  ThemeMode _readFromPrefs() {
    final v = (prefs.getString(_key) ?? 'system').trim();
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    await prefs.setString(_key, switch (m) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    });
    notifyListeners();
  }
}
