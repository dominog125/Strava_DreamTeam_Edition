import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/navigation/app_routes.dart';
import 'package:mini_strava/features/auth/domain/usecases/login_usecase.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Podaj email';
    if (!s.contains('@')) return 'Nieprawidłowy email';
    return null;
  }

  String? validatePassword(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Podaj hasło';
    if (s.length < 6) return 'Hasło jest za krótkie';
    return null;
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> submit(BuildContext context) async {
    if (isLoading) return;

    final ok = formKey.currentState?.validate() ?? false;
    if (!ok) return;

    isLoading = true;
    notifyListeners();

    try {
      final login = sl<LoginUseCase>();

      await login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logowanie nieudane: $e')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}