import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/navigation/app_routes.dart';

import 'package:mini_strava/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_user_stats_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/entities/user_stats.dart';

import 'package:mini_strava/features/profile/domain/entities/user_profile.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController c;
  late final LogoutUseCase _logout;
  late final GetUserStatsUseCase _getStats;

  UserStats? _stats;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    c = ProfileController();
    _logout = sl<LogoutUseCase>();
    _getStats = sl<GetUserStatsUseCase>();

    c.addListener(_onChanged);
    c.load();
    _loadStats();
  }

  void _onChanged() => setState(() {});

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final s = await _getStats();
      if (!mounted) return;
      setState(() {
        _stats = s;
        _statsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stats = const UserStats(workoutsCount: 0, totalDistanceKm: 0, avgSpeedKmH: 0);
        _statsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    c.removeListener(_onChanged);
    c.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final birthDateText =
    c.birthDate == null ? '-' : DateFormat('yyyy-MM-dd').format(c.birthDate!);
    final fullName = '${c.firstName.text} ${c.lastName.text}'.trim();
    final heightText = _withUnitOrDash(c.heightCm.text, 'cm');
    final weightText = _withUnitOrDash(c.weightKg.text, 'kg');

    final workouts = _stats?.workoutsCount ?? 0;
    final totalDist = _stats?.totalDistanceKm ?? 0.0;
    final avgSpeed = _stats?.avgSpeedKmH ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ustawienia profilu',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profileSettings).then((_) async {
                await c.load();
                await _loadStats();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () async {
              await _logout();
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
        ],
      ),
      body: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              fullName.isEmpty ? 'Brak danych' : fullName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),


            if (_statsLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatTile(label: 'Treningi', value: workouts.toString()),
                  _StatTile(
                    label: 'Dystans',
                    value: '${totalDist.toStringAsFixed(1)} km',
                  ),
                  _StatTile(
                    label: 'Śr. prędkość',
                    value: '${avgSpeed.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),

            const SizedBox(height: 28),


            _InfoRow(label: 'Data urodzenia', value: birthDateText),
            _InfoRow(label: 'Płeć', value: _genderLabel(c.gender)),
            _InfoRow(label: 'Wzrost', value: heightText),
            _InfoRow(label: 'Waga', value: weightText),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.activity),
                icon: const Icon(Icons.directions_run),
                label: const Text('Moje aktywności'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.activityHistory);
                  if (!mounted) return;
                  await _loadStats(); 
                },
                icon: const Icon(Icons.history),
                label: const Text('Historia aktywności'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Mężczyzna';
      case Gender.female:
        return 'Kobieta';
      case Gender.other:
        return 'Inna';
      case Gender.notSet:
        return '-';
    }
  }

  String _withUnitOrDash(String raw, String unit) {
    final s = raw.trim();
    if (s.isEmpty) return '-';
    return '$s $unit';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 12),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
