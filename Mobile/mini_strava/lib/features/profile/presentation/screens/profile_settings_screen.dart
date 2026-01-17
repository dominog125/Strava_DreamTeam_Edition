import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../controller/profile_controller.dart';
import '../../domain/entities/user_profile.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final ProfileController c;

  @override
  void initState() {
    super.initState();
    c = ProfileController();
    c.addListener(_onChanged);
    c.load();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onChanged);
    c.disposeControllers();
    c.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile == null) return;
      c.setAvatarPath(xfile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać avatara: $e')),
      );
    }
  }

  Future<void> _deleteAvatar() async {
    await c.deleteAvatar(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = c.birthDate == null
        ? 'Wybierz datę'
        : DateFormat('yyyy-MM-dd').format(c.birthDate!);

    final local = (c.avatarPath ?? '').trim();
    final hasLocal = local.isNotEmpty;
    final hasApi = c.avatarBytes != null && c.avatarBytes!.isNotEmpty;

    ImageProvider? avatarProvider;
    if (hasLocal) {
      avatarProvider = FileImage(File(local));
    } else if (hasApi) {
      avatarProvider = MemoryImage(c.avatarBytes!);
    }

    final hasAvatar = hasLocal || hasApi;

    // żeby obramówka była zawsze widoczna (nie ginęła na ciemnym tle)
    final outlineColor =
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: c.formKey,
          child: ListView(
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // lekko w prawo
                      const SizedBox(width: 6),

                      // większy avatar, ale dalej mieści się w kafelku
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),

                      const SizedBox(width: 20),

                      // przyciski bliżej prawej krawędzi
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: c.isLoading ? null : _pickAvatar,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: Text(
                                  hasAvatar ? 'Zmień avatar' : 'Wybierz avatar',
                                ),
                              ),
                              const SizedBox(height: 8),

                              // obramówka zawsze widoczna
                              if (hasAvatar)
                                OutlinedButton.icon(
                                  onPressed: c.isLoading ? null : _deleteAvatar,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Usuń avatar'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: outlineColor,
                                      width: 1.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: c.firstName,
                decoration: const InputDecoration(labelText: 'Imię'),
                validator: (v) => c.validateName(v, 'imię'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: c.lastName,
                decoration: const InputDecoration(labelText: 'Nazwisko'),
                validator: (v) => c.validateName(v, 'nazwisko'),
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data urodzenia'),
                subtitle: Text(dateText),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: c.isLoading
                    ? null
                    : () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: c.birthDate ??
                        DateTime(now.year - 18, 1, 1),
                    firstDate: DateTime(1900, 1, 1),
                    lastDate: now,
                  );
                  if (picked != null) c.setBirthDate(picked);
                },
              ),
              const SizedBox(height: 6),

              DropdownButtonFormField<Gender>(
                initialValue: c.gender,
                decoration: const InputDecoration(labelText: 'Płeć'),
                items: const [
                  DropdownMenuItem(
                      value: Gender.notSet, child: Text('Nie podano')),
                  DropdownMenuItem(
                      value: Gender.male, child: Text('Mężczyzna')),
                  DropdownMenuItem(
                      value: Gender.female, child: Text('Kobieta')),
                  DropdownMenuItem(value: Gender.other, child: Text('Inna')),
                ],
                onChanged:
                c.isLoading ? null : (g) => c.setGender(g ?? Gender.notSet),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: c.heightCm,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Wzrost (cm)'),
                validator: c.validateHeight,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: c.weightKg,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Waga (kg)'),
                validator: c.validateWeight,
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isLoading ? null : () => c.save(context),
                  child: c.isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Zapisz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
