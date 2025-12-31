import 'package:flutter/material.dart';
import 'login_controller.dart';

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
    c.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onControllerChanged);
    c.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: c.formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Text(
                  'Witaj 👋',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Zaloguj się, aby kontynuować',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: c.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: c.validateEmail,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: c.passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Hasło',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: c.validatePassword,
                  onFieldSubmitted: (_) => c.submit(context),
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

                const SizedBox(height: 10),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text('Rejestracja'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/reset'),
                      child: const Text('Reset hasła'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

