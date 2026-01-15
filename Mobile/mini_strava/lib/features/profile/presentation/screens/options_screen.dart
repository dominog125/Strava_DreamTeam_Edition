import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  AppThemeMode _mode = AppThemeMode.system;

  IconData _modeIcon(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
      case AppThemeMode.system:
        return Icons.phone_android_outlined;
    }
  }

  String _modeLabel(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.light:
        return 'Jasny';
      case AppThemeMode.dark:
        return 'Ciemny';
      case AppThemeMode.system:
        return 'Automatyczny';
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = switch (_mode) {
        AppThemeMode.system => AppThemeMode.light,
        AppThemeMode.light => AppThemeMode.dark,
        AppThemeMode.dark => AppThemeMode.system,
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tryb: ${_modeLabel(_mode)}')),
    );

    // TODO: później podepniesz pod ThemeController/Bloc/Provider i zapis w prefs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opcje')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: zmiana języka (później)
                },
                icon: const Icon(Icons.language_outlined),
                label: const Text('Zmień język'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleMode,
                icon: Icon(_modeIcon(_mode)),
                label: Text('Zmień tryb: ${_modeLabel(_mode)}'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: usuń konto (później)
                },
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Usuń konto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
