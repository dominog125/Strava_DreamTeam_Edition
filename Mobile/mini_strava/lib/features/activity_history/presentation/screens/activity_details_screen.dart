import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_details.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_activity_details_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/update_activity_meta_usecase.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final String id;
  const ActivityDetailsScreen({super.key, required this.id});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late final GetActivityDetailsUseCase _getDetails;
  late final UpdateActivityMetaUseCase _updateMeta;

  bool _loading = true;
  String? _error;
  ActivityDetails? _details;

  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  ActivityType _type = ActivityType.unknown;
  String? _photoPath;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _getDetails = sl<GetActivityDetailsUseCase>();
    _updateMeta = sl<UpdateActivityMetaUseCase>();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final d = await _getDetails(widget.id);
      if (!mounted) return;

      _details = d;
      _titleCtrl.text = (d.summary.title ?? '');
      _noteCtrl.text = (d.summary.note ?? '');
      _type = d.summary.type;
      _photoPath = d.summary.photoPath;

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Nie udało się pobrać szczegółów: $e';
        _loading = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile == null) return;
      setState(() => _photoPath = xfile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać zdjęcia: $e')),
      );
    }
  }

  void _removePhoto() {
    setState(() => _photoPath = null);
  }

  Future<void> _save() async {
    if (_details == null) return;

    final title = _titleCtrl.text.trim();
    final note = _noteCtrl.text.trim();
    final clearTitle = title.isEmpty;
    final clearNote = note.isEmpty;
    final clearPhoto = (_photoPath == null);

    setState(() => _saving = true);
    try {
      await _updateMeta(
        id: widget.id,
        type: _type,
        title: clearTitle ? null : title,
        note: clearNote ? null : note,
        photoPath: _photoPath,
        clearTitle: clearTitle,
        clearNote: clearNote,
        clearPhoto: clearPhoto,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // odświeża historię
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _details;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły aktywności'),
        actions: [
          TextButton(
            onPressed: (_saving || _loading || d == null) ? null : _save,
            child: _saving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Zapisz'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      )
          : d == null
          ? const SizedBox.shrink()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1) CHIP TYPU NA GÓRZE
          Align(
            alignment: Alignment.centerLeft,
            child: _TypeChip(type: _type, big: true),
          ),
          const SizedBox(height: 10),

          // data (opcjonalnie, wygląda dobrze)
          Text(
            DateFormat('yyyy-MM-dd').format(d.summary.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // 2) ZMIANA TYPU
          DropdownButtonFormField<ActivityType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Typ aktywności',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: ActivityType.unknown,
                child: Text('Nie podano'),
              ),
              DropdownMenuItem(
                value: ActivityType.run,
                child: Text('Bieg'),
              ),
              DropdownMenuItem(
                value: ActivityType.bike,
                child: Text('Rower'),
              ),
              DropdownMenuItem(
                value: ActivityType.walk,
                child: Text('Spacer'),
              ),
            ],
            onChanged: (v) =>
                setState(() => _type = v ?? ActivityType.unknown),
          ),
          const SizedBox(height: 16),

          // 3) NAZWA AKTYWNOŚCI (POD TYPEM)
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Nazwa aktywności',
              hintText: 'np. Interwały czasowe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 4) NOTATKA
          TextFormField(
            controller: _noteCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Notatka',
              hintText: 'Dodaj notatkę…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 5) ZDJĘCIE
          _PhotoCard(
            photoPath: _photoPath,
            onPickPhoto: _pickPhoto,
            onRemove: _removePhoto,
          ),
          const SizedBox(height: 16),

          // 6) STATYSTYKI (bez zmian)
          _StatsCard(details: d),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemove;

  const _PhotoCard({
    required this.photoPath,
    required this.onPickPhoto,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoPath ?? '').trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zdjęcie', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: hasPhoto
                    ? Image.file(File(photoPath!), fit: BoxFit.cover)
                    : Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(hasPhoto ? 'Zmień zdjęcie' : 'Dodaj zdjęcie'),
                  ),
                ),
                if (hasPhoto) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Usuń zdjęcie',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final ActivityDetails details;
  const _StatsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final s = details.summary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statystyki', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _Stat(label: 'Czas', value: _formatDuration(s.duration)),
                _Stat(label: 'Dystans', value: '${s.distanceKm.toStringAsFixed(2)} km'),
                _Stat(label: 'Tempo', value: '${s.paceMinPerKm.toStringAsFixed(1)} min/km'),
                _Stat(label: 'Śr. prędkość', value: '${s.avgSpeedKmH.toStringAsFixed(1)} km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ActivityType type;
  final bool big;

  const _TypeChip({required this.type, this.big = false});

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final IconData icon;
    late final Color color;

    switch (type) {
      case ActivityType.run:
        text = 'Bieg';
        icon = Icons.directions_run;
        color = Colors.orange;
        break;
      case ActivityType.bike:
        text = 'Rower';
        icon = Icons.directions_bike;
        color = Colors.green;
        break;
      case ActivityType.walk:
        text = 'Spacer';
        icon = Icons.directions_walk;
        color = Colors.blue;
        break;
      case ActivityType.unknown:
        text = 'Nie podano';
        icon = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: big ? 18 : 16, color: Colors.white),
      label: Text(text),
      backgroundColor: color,
      labelStyle: TextStyle(
        color: Colors.white,
        fontSize: big ? 14 : 12,
        fontWeight: big ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: big ? 10 : 6,
        vertical: big ? 6 : 2,
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
}
