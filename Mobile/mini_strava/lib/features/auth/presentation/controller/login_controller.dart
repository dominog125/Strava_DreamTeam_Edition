import 'package:flutter/material.dart';
// IMPORTANT: NO API CALLS HERE.
// API HERE: NIE — tu tylko usecase (domain). Requesty są w data/datasources.
import '../../../../core/di/injector.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final LoginUseCase _loginUseCase = sl<LoginUseCase>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Wpisz email';
    if (!s.contains('@')) return 'Niepoprawny email';
    return null;
  }

  String? validatePassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Wpisz hasło';
    if (s.length < 8) return 'Minimum 8 znaków';
    return null;
  }

  Future<void> submit(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    try {
      await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logowanie OK (FAKE repo, bez API)')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd logowania')),
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
