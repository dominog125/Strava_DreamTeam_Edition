import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/auth/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final LoginUseCase _loginUseCase = sl<LoginUseCase>();
  final AuthSession _session = sl<AuthSession>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Wpisz email';
    if (!s.contains('@') && s != 'admin') return 'Niepoprawny email';
    return null;
  }

  String? validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'Wpisz hasło';
    return null;
  }

  Future<void> submit(BuildContext context) async {
    if (_isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);

    try {
      await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _session.login();

      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(
        AppRoutes.home,
            (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błędny login lub hasło')),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
