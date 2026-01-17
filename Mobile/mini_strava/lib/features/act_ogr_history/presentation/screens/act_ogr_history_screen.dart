import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';

import 'act_ogr_details_screen.dart';

class ActOgrHistoryScreen extends StatefulWidget {
  const ActOgrHistoryScreen({super.key});

  @override
  State<ActOgrHistoryScreen> createState() => _ActOgrHistoryScreenState();
}

enum _SortField { date, distance }
enum _SortDir { desc, asc }

class _ActOgrHistoryScreenState extends State<ActOgrHistoryScreen> {
  late final Dio _dio;

  bool _loading = true;
  String? _error;

  List<_ApiActivity> _items = const [];

  ActivityType? _typeFilter;
  _SortField _sortField = _SortField.date;
  _SortDir _sortDir = _SortDir.desc;

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get(
        '/api/Activities',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'accept': 'text/plain'},
        ),
      );

      final data = res.data;
      final decoded = data is String ? jsonDecode(data) : data;

      final list = (decoded as List)
          .whereType<Map>()
          .map((e) => _ApiActivity.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _items = list;
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

  List<_ApiActivity> _applyFilterAndSort(List<_ApiActivity> input) {
    Iterable<_ApiActivity> out = input;

    if (_typeFilter != null) {
      out = out.where((a) => a.type == _typeFilter);
    }

    final list = out.toList();

    int cmp(_ApiActivity a, _ApiActivity b) {
      int base;
      switch (_sortField) {
        case _SortField.date:
          base = a.createdAt.compareTo(b.createdAt);
          break;
        case _SortField.distance:
          base = a.lengthInKm.compareTo(b.lengthInKm);
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

  Future<void> _openDetails(String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActOgrDetailsScreen(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _applyFilterAndSort(_items);

    return Scaffold(
      appBar: AppBar(title: const Text('Historia aktywności')),
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
                child: Center(
                  child: Text('Brak aktywności dla wybranych filtrów'),
                ),
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


class _ApiActivity {
  final String id;
  final String name;
  final String description;
  final double lengthInKm;
  final double paceMinPerKm;
  final double speedKmPerHour;
  final int activeSeconds;
  final String activityCategoryId;
  final String categoryName;
  final DateTime createdAt;

  _ApiActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.lengthInKm,
    required this.paceMinPerKm,
    required this.speedKmPerHour,
    required this.activeSeconds,
    required this.activityCategoryId,
    required this.categoryName,
    required this.createdAt,
  });

  factory _ApiActivity.fromJson(Map<String, dynamic> json) {
    final catName = (json['categoryName'] ?? '').toString();

    DateTime parseDate(dynamic v) {
      final s = (v ?? '').toString().trim();
      return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse((v ?? '').toString().replaceAll(',', '.')) ?? 0.0;
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse((v ?? '').toString()) ?? 0;
    }

    return _ApiActivity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      lengthInKm: parseDouble(json['lengthInKm']),
      paceMinPerKm: parseDouble(json['paceMinPerKm']),
      speedKmPerHour: parseDouble(json['speedKmPerHour']),
      activeSeconds: parseInt(json['activeSeconds']),
      activityCategoryId: (json['activityCategoryId'] ?? '').toString(),
      categoryName: catName,
      createdAt: parseDate(json['createdAt']),
    );
  }

  ActivityType get type {
    final s = categoryName.trim().toLowerCase();
    if (s.contains('bieg') || s.contains('run')) return ActivityType.run;
    if (s.contains('rower') || s.contains('bike')) return ActivityType.bike;
    if (s.contains('hiking') || s.contains('spacer') || s.contains('walk')) {
      return ActivityType.walk;
    }
    return ActivityType.unknown;
  }

  Duration get duration => Duration(seconds: activeSeconds);
  double get distanceKm => lengthInKm;
  double get avgSpeedKmH => speedKmPerHour;
  double get pace => paceMinPerKm;
  DateTime get date => createdAt;

  String? get title {
    final t = name.trim();
    return t.isEmpty ? null : t;
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
  final _ApiActivity activity;
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
                  _Stat(label: 'Tempo', value: '${activity.pace.toStringAsFixed(1)} min/km'),
                  _Stat(
                    label: 'Śr. prędkość',
                    value: '${activity.avgSpeedKmH.toStringAsFixed(1)} km/h',
                  ),
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
