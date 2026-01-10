import 'package:flutter/material.dart';

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

    if (!s.contains('@') && s != 'admin') return 'Niepoprawny email';
    return null;
  }

  String? validatePassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Wpisz hasło';

    return null;
  }

  Future<void> submit(BuildContext context) async {
    if (_isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);

    try {
      debugPrint('LOGIN SUBMIT: ${emailController.text.trim()}');

      await _loginUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;
      debugPrint('LOGIN OK -> navigating to /profile');


      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/profile',
              (route) => false,
        );
      });
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
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

