import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';

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
      initialRoute: AppRoutes.gate,
      routes: AppRouter.routes,
    );
  }
}
