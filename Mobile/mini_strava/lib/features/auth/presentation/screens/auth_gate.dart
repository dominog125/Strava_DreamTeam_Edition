import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/auth/domain/usecases/get_cached_tokens_usecase.dart';

import 'login_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

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
          return const ProfileScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
