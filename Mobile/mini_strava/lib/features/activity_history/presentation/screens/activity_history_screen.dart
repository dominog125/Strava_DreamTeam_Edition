import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_summary.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_activity_history_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/add_manual_activity_usecase.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late final GetActivityHistoryUseCase _getHistory;
  late final AddManualActivityUseCase _addManual;

  bool _loading = true;
  String? _error;
  List<ActivitySummary> _items = const [];

  @override
  void initState() {
    super.initState();
    _getHistory = sl<GetActivityHistoryUseCase>();
    _addManual = sl<AddManualActivityUseCase>();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _getHistory();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Nie udało się pobrać historii';
        _loading = false;
      });
    }
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<_ManualActivityInput>(
      context: context,
      builder: (_) => const _AddActivityDialog(),
    );

    if (result == null) return;

    await _addManual(
      date: result.date,
      type: result.type,
      duration: Duration(minutes: result.durationMinutes),
      distanceKm: result.distanceKm,
    );

    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historia aktywności')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj'),
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
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Spróbuj ponownie')),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ActivityCard(activity: _items[index]),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivitySummary activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TypeChip(type: activity.type),
                Text(DateFormat('yyyy-MM-dd').format(activity.date),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'Czas', value: _formatDuration(activity.duration)),
                _Stat(label: 'Dystans', value: '${activity.distanceKm.toStringAsFixed(2)} km'),
                _Stat(label: 'Tempo', value: '${activity.paceMinPerKm.toStringAsFixed(1)} min/km'),
                _Stat(label: 'Śr. prędkość', value: '${activity.avgSpeedKmH.toStringAsFixed(1)} km/h'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ActivityType type;
  const _TypeChip({required this.type});

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
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(text),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
}

/* ---------------- Dialog + input ---------------- */

class _ManualActivityInput {
  final DateTime date;
  final ActivityType type;
  final int durationMinutes;
  final double distanceKm;

  const _ManualActivityInput({
    required this.date,
    required this.type,
    required this.durationMinutes,
    required this.distanceKm,
  });
}

class _AddActivityDialog extends StatefulWidget {
  const _AddActivityDialog();

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  ActivityType _type = ActivityType.run;

  final _durationMin = TextEditingController();
  final _distanceKm = TextEditingController();

  @override
  void dispose() {
    _durationMin.dispose();
    _distanceKm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj aktywność'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000, 1, 1),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ActivityType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Typ'),
                items: const [
                  DropdownMenuItem(value: ActivityType.run, child: Text('Bieg')),
                  DropdownMenuItem(value: ActivityType.bike, child: Text('Rower')),
                  DropdownMenuItem(value: ActivityType.walk, child: Text('Spacer')),
                ],
                onChanged: (v) => setState(() => _type = v ?? ActivityType.run),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationMin,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Czas (minuty)'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Podaj czas w minutach';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _distanceKm,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Dystans (km)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Podaj dystans';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;

            Navigator.pop(
              context,
              _ManualActivityInput(
                date: _date,
                type: _type,
                durationMinutes: int.parse(_durationMin.text.trim()),
                distanceKm: double.parse(_distanceKm.text.trim().replaceAll(',', '.')),
              ),
            );
          },
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}
