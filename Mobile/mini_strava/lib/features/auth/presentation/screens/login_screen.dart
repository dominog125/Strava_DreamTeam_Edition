import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController c;

  @override
  void initState() {
    super.initState();
    c = LoginController();
    c.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onChanged);
    c.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: c.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: c.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: c.validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: c.passwordController,
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                validator: c.validatePassword,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isLoading ? null : () => c.submit(context),
                  child: c.isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Zaloguj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
