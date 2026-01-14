import 'package:flutter/material.dart';
import 'package:mini_strava/features/profile/presentation/controller/profile_controller.dart';
import '../widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenInvites;
  final VoidCallback? onOpenRanking;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    this.onOpenFriends,
    this.onOpenInvites,
    this.onOpenRanking,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileController _profile;

  String? _avatarPathOrUrl;
  String? _initials;

  @override
  void initState() {
    super.initState();
    _profile = ProfileController();
    _profile.addListener(_syncFromProfile);
    _profile.load();
  }

  void _syncFromProfile() {
    final avatar = (_profile.avatarPathOrUrl ?? '').trim();

    final fn = _profile.firstName.text.trim();
    final ln = _profile.lastName.text.trim();
    final initials =
    ((fn.isNotEmpty ? fn[0] : '') + (ln.isNotEmpty ? ln[0] : '')).trim();

    if (!mounted) return;
    setState(() {
      _avatarPathOrUrl = avatar.isEmpty ? null : avatar;
      _initials = initials.isEmpty ? 'U' : initials.toUpperCase();
    });
  }

  @override
  void dispose() {
    _profile.removeListener(_syncFromProfile);
    _profile.disposeControllers();
    super.dispose();
  }

  Future<void> _openProfileAndRefresh() async {
    // ważne: czekamy aż wrócisz z profilu, a potem odświeżamy dane
    await Navigator.pushNamed(context, '/profile');
    if (!mounted) return;
    await _profile.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onOpenRanking: widget.onOpenRanking ?? () {},
        onOpenFriends: widget.onOpenFriends ?? () {},
        onOpenInvites: widget.onOpenInvites ?? () {},
        onOpenProfile: _openProfileAndRefresh,
        avatarUrl: _avatarPathOrUrl,
        initials: _initials,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tu potem: feed / ostatnie aktywności / statystyki itd.
          ],
        ),
      ),
    );
  }
}
