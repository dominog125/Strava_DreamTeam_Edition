import 'package:flutter/material.dart';

import 'app_routes.dart';

import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/options_screen.dart';

import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/activity_history/presentation/screens/activity_history_screen.dart';

import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/invites/presentation/screens/invites_inbox_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.gate: (_) => const AuthGate(),
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),
    AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),

    AppRoutes.home: (ctx) => HomeScreen(
      onOpenProfile: () => Navigator.pushNamed(ctx, AppRoutes.profile),
      onOpenFriends: () => Navigator.pushNamed(ctx, AppRoutes.friends),
      onOpenInvites: () => Navigator.pushNamed(ctx, AppRoutes.invites),
      onOpenRanking: () => Navigator.pushNamed(ctx, AppRoutes.ranking),
    ),

    AppRoutes.profile: (_) => const ProfileScreen(),
    AppRoutes.profileSettings: (_) => const ProfileSettingsScreen(),
    AppRoutes.options: (_) => const OptionsScreen(),

    AppRoutes.activity: (_) => const ActivityScreen(),
    AppRoutes.activityHistory: (_) => const ActivityHistoryScreen(),

    AppRoutes.friends: (_) => const FriendsScreen(),
    AppRoutes.invites: (_) => const InvitesInboxScreen(),
    AppRoutes.ranking: (_) => const RankingScreen(),
  };
}
