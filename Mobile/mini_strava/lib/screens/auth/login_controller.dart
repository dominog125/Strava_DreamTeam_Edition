import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Future<void> submit(BuildContext context) async {
    if (!validate()) return;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logowanie: OK (na razie bez API)')),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Wpisz email';
    if (!s.contains('@') || s.length < 5) return 'Niepoprawny email';
    return null;
  }

  String? validatePassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Wpisz hasło';
    if (s.length < 8) return 'Minimum 8 znaków';
    return null;
  }
}
