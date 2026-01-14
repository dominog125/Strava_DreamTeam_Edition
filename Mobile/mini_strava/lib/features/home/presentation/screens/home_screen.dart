import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import 'package:mini_strava/theme/app_colors.dart';


class HomeScreen extends StatelessWidget {

  final VoidCallback onOpenProfile;


  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenInvites;
  final VoidCallback? onOpenRanking;


  final String? avatarUrl;
  final String? initials;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    this.onOpenFriends,
    this.onOpenInvites,
    this.onOpenRanking,
    this.avatarUrl,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onOpenFriends: onOpenFriends ?? () {},
        onOpenInvites: onOpenInvites ?? () {},
        onOpenProfile: onOpenProfile,
        avatarUrl: avatarUrl,
        initials: initials,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: onOpenRanking ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ranking użytkowników',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
