import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_routes.dart';

import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController c;
  late final LogoutUseCase _logout;

  @override
  void initState() {
    super.initState();
    c = ProfileController();
    _logout = sl<LogoutUseCase>();

    c.addListener(_onChanged);
    c.load();
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
    final birthDateText =
    c.birthDate == null ? '-' : DateFormat('yyyy-MM-dd').format(c.birthDate!);

    final fullName = '${c.firstName.text} ${c.lastName.text}'.trim();
    final heightText = _withUnitOrDash(c.heightCm.text, 'cm');
    final weightText = _withUnitOrDash(c.weightKg.text, 'kg');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ustawienia profilu',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profileSettings)
                  .then((_) => c.load());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () async {
              await _logout();
              if (!context.mounted) return;

              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                AppRoutes.login,
                    (_) => false,
              );
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
            const SizedBox(height: 24),
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

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
