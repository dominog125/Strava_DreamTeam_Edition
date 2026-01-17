import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/auth/domain/usecases/register_usecase.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureRepeat = true;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final register = sl<RegisterUseCase>();
      await register(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejestracja udana. Możesz się zalogować.')),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      String msg = 'Rejestracja nieudana';
      if (code == 400) {
        msg = 'Rejestracja nieudana: niepoprawne dane lub email zajęty';
      } else if (code == 409) {
        msg = 'Rejestracja nieudana: użytkownik już istnieje';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejestracja nieudana')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Text('Zaczynajmy 👋', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'Utwórz konto, aby kontynuować',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _username,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa użytkownika',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                  (v != null && v.trim().length >= 3) ? null : 'Min. 3 znaki',
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => (v != null && v.contains('@')) ? null : 'Niepoprawny email',
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _password,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Hasło',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) =>
                  (v != null && v.length >= 8) ? null : 'Min. 8 znaków',
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _repeat,
                  obscureText: _obscureRepeat,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Powtórz hasło',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureRepeat = !_obscureRepeat),
                      icon: Icon(_obscureRepeat ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) => (v == _password.text) ? null : 'Hasła się różnią',
                  onFieldSubmitted: (_) => _loading ? null : _submit(),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Zarejestruj'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
