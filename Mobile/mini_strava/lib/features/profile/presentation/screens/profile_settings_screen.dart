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


      setState(() {
        c.avatarPathOrUrl = xfile.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać avatara: $e')),
      );
    }
  }

  void _clearAvatar() {
    setState(() {
      c.avatarPathOrUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateText = c.birthDate == null
        ? 'Wybierz datę'
        : DateFormat('yyyy-MM-dd').format(c.birthDate!);

    final avatar = (c.avatarPathOrUrl ?? '').trim();
    final hasLocalAvatar = avatar.isNotEmpty && !avatar.startsWith('http');

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
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: hasLocalAvatar ? FileImage(File(avatar)) : null,
                        child: !hasLocalAvatar
                            ? const Icon(Icons.person, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton.icon(
                              onPressed: c.isLoading ? null : _pickAvatar,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(hasLocalAvatar ? 'Zmień avatar' : 'Wybierz avatar'),
                            ),
                            const SizedBox(height: 6),
                            if ((c.avatarPathOrUrl ?? '').trim().isNotEmpty)
                              TextButton.icon(
                                onPressed: c.isLoading ? null : _clearAvatar,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Usuń avatar'),
                              ),
                          ],
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
                    initialDate: c.birthDate ?? DateTime(now.year - 18, 1, 1),
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
                  DropdownMenuItem(value: Gender.notSet, child: Text('Nie podano')),
                  DropdownMenuItem(value: Gender.male, child: Text('Mężczyzna')),
                  DropdownMenuItem(value: Gender.female, child: Text('Kobieta')),
                  DropdownMenuItem(value: Gender.other, child: Text('Inna')),
                ],
                onChanged: c.isLoading ? null : (g) => c.setGender(g ?? Gender.notSet),
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
