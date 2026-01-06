import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';

class ProfileController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final heightCm = TextEditingController();
  final weightKg = TextEditingController();

  DateTime? birthDate;
  Gender gender = Gender.notSet;

  String? avatarPathOrUrl; // TODO(API/LOCAL): picker + upload

  final GetProfileUseCase _get = sl<GetProfileUseCase>();
  final SaveProfileUseCase _save = sl<SaveProfileUseCase>();

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> load() async {
    _setLoading(true);
    try {
      final profile = await _get();
      if (profile != null) {
        firstName.text = profile.firstName;
        lastName.text = profile.lastName;
        heightCm.text = profile.heightCm.toString();
        weightKg.text = profile.weightKg.toString();
        birthDate = profile.birthDate;
        gender = profile.gender;
        avatarPathOrUrl = profile.avatarPathOrUrl;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> save(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (birthDate == null) {
      _snack(context, 'Wybierz datę urodzenia');
      return;
    }

    final profile = UserProfile(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      birthDate: birthDate!,
      gender: gender,
      heightCm: int.parse(heightCm.text.trim()),
      weightKg: double.parse(weightKg.text.trim().replaceAll(',', '.')),
      avatarPathOrUrl: avatarPathOrUrl,
    );

    _setLoading(true);
    try {
      await _save(profile);
      if (!context.mounted) return;
      _snack(context, 'Zapisano profil ✅');
    } catch (_) {
      if (!context.mounted) return;
      _snack(context, 'Błąd zapisu profilu');
    } finally {
      _setLoading(false);
    }
  }

  void setBirthDate(DateTime d) {
    birthDate = d;
    notifyListeners();
  }

  void setGender(Gender g) {
    gender = g;
    notifyListeners();
  }

  String? validateName(String? v, String fieldName) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Wpisz $fieldName';
    if (s.length < 2) return '$fieldName jest za krótkie';
    return null;
  }

  String? validateHeight(String? v) {
    final s = (v ?? '').trim();
    final n = int.tryParse(s);
    if (n == null) return 'Wpisz wzrost (cm)';
    if (n < 80 || n > 250) return 'Podaj realistyczny wzrost';
    return null;
  }

  String? validateWeight(String? v) {
    final s = (v ?? '').trim().replaceAll(',', '.');
    final n = double.tryParse(s);
    if (n == null) return 'Wpisz wagę (kg)';
    if (n < 20 || n > 300) return 'Podaj realistyczną wagę';
    return null;
  }

  void disposeControllers() {
    firstName.dispose();
    lastName.dispose();
    heightCm.dispose();
    weightKg.dispose();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
