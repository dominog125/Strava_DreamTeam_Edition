import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

class MiniStravaApp extends StatelessWidget {
  const MiniStravaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniStrava',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      //  START Z AUTH GATE
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate(),
        ...AppRouter.routes,
      },
    );
  }
}
