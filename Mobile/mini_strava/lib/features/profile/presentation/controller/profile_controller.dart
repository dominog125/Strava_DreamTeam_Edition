import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import '../../domain/usecases/get_avatar_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/delete_avatar_usecase.dart';

class ProfileController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final heightCm = TextEditingController();
  final weightKg = TextEditingController();

  DateTime? birthDate;
  Gender gender = Gender.notSet;


  String? avatarPath;


  Uint8List? avatarBytes;

  final GetProfileUseCase _getProfile = sl<GetProfileUseCase>();
  final SaveProfileUseCase _saveProfile = sl<SaveProfileUseCase>();
  final GetAvatarUseCase _getAvatar = sl<GetAvatarUseCase>();
  final UploadAvatarUseCase _uploadAvatar = sl<UploadAvatarUseCase>();
  final DeleteAvatarUseCase _deleteAvatar = sl<DeleteAvatarUseCase>();

  bool _loading = false;
  bool get isLoading => _loading;

  // ===================== LOAD =====================
  Future<void> load() async {
    _setLoading(true);
    try {

      try {
        final profile = await _getProfile();
        if (profile != null) {
          firstName.text = profile.firstName;
          lastName.text = profile.lastName;

          if (profile.heightCm == null) {
            heightCm.text = '';
          } else {
            heightCm.text = profile.heightCm.toString();
          }

          if (profile.weightKg == null) {
            weightKg.text = '';
          } else {
            weightKg.text = profile.weightKg.toString();
          }

          birthDate = profile.birthDate;
          gender = profile.gender;
        }
      } catch (_) {

      }


      try {
        avatarBytes = await _getAvatar();
      } catch (_) {
        avatarBytes = null;
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===================== SAVE =====================
  Future<void> save(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (birthDate == null) {
      _snack(context, 'Wybierz datę urodzenia');
      return;
    }

    final profile = UserProfile(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      birthDate: birthDate,
      gender: gender,
      heightCm: int.tryParse(heightCm.text.trim()),
      weightKg: double.tryParse(weightKg.text.trim().replaceAll(',', '.')),

      avatarPathOrUrl: null,
    );

    _setLoading(true);
    try {

      final local = (avatarPath ?? '').trim();
      if (local.isNotEmpty) {
        final f = File(local);
        if (await f.exists()) {
          await _uploadAvatar(f);
        }
      }


      await _saveProfile(profile);


      try {
        avatarBytes = await _getAvatar();
      } catch (_) {
        avatarBytes = null;
      }

      if (!context.mounted) return;
      _snack(context, 'Zapisano profil ✅');
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      _snack(context, 'Błąd zapisu profilu');
    } finally {
      _setLoading(false);
    }
  }

  // ===================== DELETE AVATAR =====================
  Future<void> deleteAvatar(BuildContext context) async {
    _setLoading(true);
    try {
      await _deleteAvatar();
      avatarBytes = null;
      avatarPath = null;

      if (!context.mounted) return;
      _snack(context, 'Usunięto avatar ✅');
      notifyListeners();
    } catch (_) {
      if (!context.mounted) return;
      _snack(context, 'Nie udało się usunąć avatara');
    } finally {
      _setLoading(false);
    }
  }

  // ===================== SETTERS =====================
  void setBirthDate(DateTime d) {
    birthDate = d;
    notifyListeners();
  }

  void setGender(Gender g) {
    gender = g;
    notifyListeners();
  }

  void setAvatarPath(String? path) {
    final p = (path ?? '').trim();
    avatarPath = p.isEmpty ? null : p;
    notifyListeners();
  }

  // ===================== VALIDATION =====================
  String? validateName(String? v, String fieldName) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Wpisz $fieldName';
    if (s.length < 2) return '$fieldName jest za krótkie';
    return null;
  }

  String? validateHeight(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Wpisz wzrost (cm)';
    if (n < 80 || n > 250) return 'Podaj realistyczny wzrost';
    return null;
  }

  String? validateWeight(String? v) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (n == null) return 'Wpisz wagę (kg)';
    if (n < 20 || n > 300) return 'Podaj realistyczną wagę';
    return null;
  }

  // ===================== UTILS =====================
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
