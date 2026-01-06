import 'package:flutter/material.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'login_screen.dart';

class AuthContainerScreen extends StatelessWidget {
  const AuthContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const BouncingScrollPhysics(),
      children: const [
        LoginScreen(),
        ProfileScreen(),
      ],
    );
  }
}
