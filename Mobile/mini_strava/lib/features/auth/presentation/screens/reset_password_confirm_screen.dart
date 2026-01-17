import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String? initialEmail;
  const ResetPasswordConfirmScreen({super.key, this.initialEmail});

  @override
  State<ResetPasswordConfirmScreen> createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState extends State<ResetPasswordConfirmScreen> {
  late final Dio _dio;

  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _resetting = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;
    _emailCtrl.text = (widget.initialEmail ?? '').trim();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    final newPass = _passCtrl.text;

    if (email.isEmpty || token.isEmpty || newPass.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij email, token i nowe hasło')),
      );
      return;
    }

    setState(() => _resetting = true);
    try {
      await _dio.post(
        '/api/Auth/reset-password',
        data: {
          'email': email,
          'token': token,
          'newPassword': newPass,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasło zostało zresetowane')),
      );

      Navigator.pop(context); // zamknij confirm (wróć do poprzedniego)
    } on DioException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się zresetować hasła')),
      );
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustaw nowe hasło')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Text(
                'Ustaw nowe hasło 🔑',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Wklej token z maila i ustaw nowe hasło',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _tokenCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Token',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Nowe hasło',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                onSubmitted: (_) => _resetting ? null : _resetPassword(),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetting ? null : _resetPassword,
                  child: _resetting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Resetuj hasło'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
