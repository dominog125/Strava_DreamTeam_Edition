import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../activity_history/domain/entities/activity_type.dart' as hist;
import '../../../activity_history/domain/entities/gps_point.dart';

class ActivityMetaDraft {
  final String? title;
  final String? note;
  final String? photoPath;
  final hist.ActivityType type;

  const ActivityMetaDraft({
    required this.type,
    this.title,
    this.note,
    this.photoPath,
  });
}

class ActivitySummaryScreen extends StatefulWidget {
  final hist.ActivityType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final double distanceKm;
  final List<GpsPoint> track;
  final String? routeImagePath;

  const ActivitySummaryScreen({
    super.key,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.distanceKm,
    required this.track,
    required this.routeImagePath,
  });

  @override
  State<ActivitySummaryScreen> createState() => _ActivitySummaryScreenState();
}

class _ActivitySummaryScreenState extends State<ActivitySummaryScreen> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  hist.ActivityType _type = hist.ActivityType.unknown;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
  }

  double _paceMinPerKm(double distanceKm, Duration duration) {
    if (distanceKm <= 0.0001) return 0.0;
    final minutes = duration.inSeconds / 60.0;
    final pace = minutes / distanceKm;
    return pace.isFinite ? pace : 0.0;
  }

  double _avgSpeedKmH(double distanceKm, Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds <= 0 || distanceKm <= 0.0001) return 0.0;
    final hours = seconds / 3600.0;
    final v = distanceKm / hours;
    return v.isFinite ? v : 0.0;
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xfile == null) return;
      setState(() => _photoPath = xfile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać zdjęcia: $e')),
      );
    }
  }

  void _removePhoto() => setState(() => _photoPath = null);

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final title = _titleCtrl.text.trim();
    final note = _noteCtrl.text.trim();

    if (!mounted) return;
    Navigator.pop(
      context,
      ActivityMetaDraft(
        type: _type,
        title: title.isEmpty ? null : title,
        note: note.isEmpty ? null : note,
        photoPath: _photoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy-MM-dd').format(widget.startedAt);

    final routePath = (widget.routeImagePath ?? '').trim();
    final routeFile = routePath.isEmpty ? null : File(routePath);
    final routeExists = routeFile != null && routeFile.existsSync();

    final photoPath = (_photoPath ?? '').trim();
    final hasPhoto = photoPath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podsumowanie'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Zapisz'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 6),
          Text(dateText, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),

          DropdownButtonFormField<hist.ActivityType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Typ aktywności',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: hist.ActivityType.unknown, child: Text('Nie podano')),
              DropdownMenuItem(value: hist.ActivityType.run, child: Text('Bieg')),
              DropdownMenuItem(value: hist.ActivityType.bike, child: Text('Rower')),
              DropdownMenuItem(value: hist.ActivityType.walk, child: Text('Spacer')),
            ],
            onChanged: (v) => setState(() => _type = v ?? hist.ActivityType.unknown),
          ),

          const SizedBox(height: 16),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Nazwa aktywności',
              hintText: 'np. Interwały czasowe',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
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
          Card(
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
                          ? Image.file(File(photoPath), fit: BoxFit.cover)
                          : Container(
                        color: Colors.black12,
                        child: const Center(child: Icon(Icons.image_outlined, size: 48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(hasPhoto ? 'Zmień zdjęcie' : 'Dodaj zdjęcie'),
                        ),
                      ),
                      if (hasPhoto) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _removePhoto,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Usuń zdjęcie',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trasa', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: routeExists
                          ? Image.file(routeFile, fit: BoxFit.cover)
                          : Container(
                        color: Colors.black12,
                        child: const Center(child: Icon(Icons.map_outlined, size: 48)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
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
                      _Stat(label: 'Czas', value: _formatDuration(widget.duration)),
                      _Stat(label: 'Dystans', value: '${widget.distanceKm.toStringAsFixed(2)} km'),
                      _Stat(
                        label: 'Tempo',
                        value: '${_paceMinPerKm(widget.distanceKm, widget.duration).toStringAsFixed(1)} min/km',
                      ),
                      _Stat(
                        label: 'Śr. prędkość',
                        value: '${_avgSpeedKmH(widget.distanceKm, widget.duration).toStringAsFixed(1)} km/h',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
