import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_summary.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/get_activity_history_usecase.dart';
import 'package:mini_strava/features/activity_history/domain/usecases/add_manual_activity_usecase.dart';
import 'package:mini_strava/features/activity_history/presentation/screens/activity_details_screen.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}



enum _SortField { date, distance }
enum _SortDir { desc, asc }

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late final GetActivityHistoryUseCase _getHistory;
  late final AddManualActivityUseCase _addManual;

  bool _loading = true;
  String? _error;

  List<ActivitySummary> _items = const [];


  ActivityType? _typeFilter;
  _SortField _sortField = _SortField.date;
  _SortDir _sortDir = _SortDir.desc;

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

  Future<void> _openDetails(String id) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ActivityDetailsScreen(id: id)),
    );

    if (changed == true && mounted) {
      await _load();
    }
  }

  List<ActivitySummary> _applyFilterAndSort(List<ActivitySummary> input) {
    Iterable<ActivitySummary> out = input;


    if (_typeFilter != null) {
      out = out.where((a) => a.type == _typeFilter);
    }

    final list = out.toList();


    int cmp(ActivitySummary a, ActivitySummary b) {
      int base;
      switch (_sortField) {
        case _SortField.date:
          base = a.date.compareTo(b.date);
          break;
        case _SortField.distance:
          base = a.distanceKm.compareTo(b.distanceKm);
          break;
      }
      return _sortDir == _SortDir.asc ? base : -base;
    }

    list.sort(cmp);
    return list;
  }

  void _resetFilters() {
    setState(() {
      _typeFilter = null;
      _sortField = _SortField.date;
      _sortDir = _SortDir.desc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _applyFilterAndSort(_items);

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
              ElevatedButton(
                onPressed: _load,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FiltersBar(
              typeFilter: _typeFilter,
              sortField: _sortField,
              sortDir: _sortDir,
              onTypeChanged: (v) => setState(() => _typeFilter = v),
              onSortFieldChanged: (v) => setState(() => _sortField = v),
              onSortDirChanged: (v) => setState(() => _sortDir = v),
              onReset: _resetFilters,
            ),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: Text('Brak aktywności dla wybranych filtrów')),
              )
            else
              ...List.generate(visible.length, (index) {
                final item = visible[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityCard(
                    activity: item,
                    onTap: () => _openDetails(item.id),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}


class _FiltersBar extends StatelessWidget {
  final ActivityType? typeFilter;
  final _SortField sortField;
  final _SortDir sortDir;

  final ValueChanged<ActivityType?> onTypeChanged;
  final ValueChanged<_SortField> onSortFieldChanged;
  final ValueChanged<_SortDir> onSortDirChanged;
  final VoidCallback onReset;

  const _FiltersBar({
    required this.typeFilter,
    required this.sortField,
    required this.sortDir,
    required this.onTypeChanged,
    required this.onSortFieldChanged,
    required this.onSortDirChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ActivityType?>(
                    initialValue: typeFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filtr: typ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Wszystkie')),
                      DropdownMenuItem(value: ActivityType.run, child: Text('Bieg')),
                      DropdownMenuItem(value: ActivityType.bike, child: Text('Rower')),
                      DropdownMenuItem(value: ActivityType.walk, child: Text('Spacer')),
                      DropdownMenuItem(value: ActivityType.unknown, child: Text('Nie podano')),
                    ],
                    onChanged: onTypeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<_SortField>(
                    initialValue: sortField,
                    decoration: const InputDecoration(
                      labelText: 'Sortuj po',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: _SortField.date, child: Text('Dacie')),
                      DropdownMenuItem(value: _SortField.distance, child: Text('Dystansie')),
                    ],
                    onChanged: (v) => onSortFieldChanged(v ?? _SortField.date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<_SortDir>(
                    initialValue: sortDir,
                    decoration: const InputDecoration(
                      labelText: 'Kierunek',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: _SortDir.desc, child: Text('Malejąco')),
                      DropdownMenuItem(value: _SortDir.asc, child: Text('Rosnąco')),
                    ],
                    onChanged: (v) => onSortDirChanged(v ?? _SortDir.desc),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _ActivityCard extends StatelessWidget {
  final ActivitySummary activity;
  final VoidCallback? onTap;

  const _ActivityCard({
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (activity.title ?? '').trim();

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TypeChip(type: activity.type),
                  Text(
                    DateFormat('yyyy-MM-dd').format(activity.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
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
      case ActivityType.unknown:
        text = 'Nie podano';
        icon = Icons.help_outline;
        color = Colors.grey;
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
                  DropdownMenuItem(value: ActivityType.unknown, child: Text('Nie podano')),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
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
