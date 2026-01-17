import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'reset_password_confirm_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  late final Dio _dio;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj adres email')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await _dio.post(
        '/api/Auth/forgot-password',
        data: {'email': email},
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link resetu hasła został wysłany')),
      );

      // ✅ przejście do confirm (email wstępnie uzupełniony)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordConfirmScreen(initialEmail: email),
        ),
      );
    } on DioException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się wysłać linku resetu')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset hasła')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Text(
                'Reset hasła 🔐',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Podaj email, a wyślemy Ci link i token do ustawienia nowego hasła',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onSubmitted: (_) => _sending ? null : _sendResetLink(),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendResetLink,
                  child: _sending
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Wyślij link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

