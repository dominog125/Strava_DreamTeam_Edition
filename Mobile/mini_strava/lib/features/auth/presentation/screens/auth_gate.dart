import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/navigation/app_routes.dart';
import 'package:mini_strava/features/auth/domain/usecases/get_cached_tokens_usecase.dart';
import 'package:mini_strava/features/home/presentation/screens/home_screen.dart';

import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<GetCachedTokensUseCase>()(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tokens = snapshot.data;

        if (tokens != null) {
          return HomeScreen(
            onOpenProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
            onOpenFriends: () => Navigator.pushNamed(context, AppRoutes.friends),
            onOpenInvites: () => Navigator.pushNamed(context, AppRoutes.invites),
            onOpenRanking: () => Navigator.pushNamed(context, AppRoutes.ranking),
          );
        }

        return const LoginScreen();
      },
    );
  }
}
