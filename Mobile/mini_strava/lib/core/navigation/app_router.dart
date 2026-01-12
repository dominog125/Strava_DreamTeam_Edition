import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/activity_history/presentation/screens/activity_history_screen.dart';


import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),
    AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
    AppRoutes.profile: (_) => const ProfileScreen(),
    AppRoutes.profileSettings: (_) => const ProfileSettingsScreen(),
    AppRoutes.activity: (_) => const ActivityScreen(),
    AppRoutes.activityHistory: (_) => const ActivityHistoryScreen(),
  };
}
