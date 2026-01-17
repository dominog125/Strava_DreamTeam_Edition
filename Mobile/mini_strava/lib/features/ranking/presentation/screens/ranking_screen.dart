import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late final Dio _dio;

  bool _loading = true;
  bool _offline = false;
  String? _error;

  final int _take = 5;

  late int _year;
  late int _month;

  _RankingResponse? _data;

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;

    final now = DateTime.now();
    _year = now.year;
    _month = now.month;

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _offline = false;
      _error = null;
    });

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/user/stats/ranking/monthly',
        queryParameters: {
          'year': _year,
          'month': _month,
          'take': _take,
        },
        options: Options(headers: {'accept': 'text/plain'}),
      );

      final map = (res.data ?? <String, dynamic>{});
      final parsed = _RankingResponse.fromJson(map);

      if (!mounted) return;
      setState(() {
        _data = parsed;
        _loading = false;
      });
    } on DioException catch (e) {
      final isOffline = e.error is SocketException ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout;

      if (!mounted) return;
      setState(() {
        _offline = isOffline;
        _error = isOffline ? null : 'Nie udało się pobrać rankingu';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Nie udało się pobrać rankingu';
        _loading = false;
      });
    }
  }

  void _setMonth(int m) {
    if (m == _month) return;
    setState(() => _month = m);
    _load();
  }

  void _setYear(int y) {
    if (y == _year) return;
    setState(() => _year = y);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_offline) {
      return const Scaffold(body: OfflinePlaceholder());
    }

    final d = _data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking miesięczny'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
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
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FiltersCard(
              year: _year,
              month: _month,
              take: _take,
              onYearChanged: _setYear,
              onMonthChanged: _setMonth,
            ),
            const SizedBox(height: 12),
            _RankingCard(data: d),
          ],
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final int year;
  final int month;
  final int take;

  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const _FiltersCard({
    required this.year,
    required this.month,
    required this.take,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = <int>{
      now.year - 1,
      now.year,
      now.year + 1,
    }.toList()
      ..sort();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(
                  labelText: 'Rok',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: years
                    .map(
                      (y) => DropdownMenuItem(
                    value: y,
                    child: Text('$y'),
                  ),
                )
                    .toList(),
                onChanged: (v) => onYearChanged(v ?? year),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: month, // ✅ value -> initialValue
                decoration: const InputDecoration(
                  labelText: 'Miesiąc',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: List.generate(
                  12,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'.padLeft(2, '0')),
                  ),
                ),
                onChanged: (v) => onMonthChanged(v ?? month),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOP $take',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'dystans (km)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final _RankingResponse data;

  const _RankingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final users = data.topUsers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking: ${data.year}-${data.month.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (users.isEmpty)
              const Text('Brak danych do wyświetlenia')
            else
              ...List.generate(users.length, (i) {
                final u = users[i];
                final place = i + 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$place.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          u.userName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        '${u.totalDistanceKm.toStringAsFixed(2)} km',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}



class _RankingResponse {
  final int year;
  final int month;
  final List<_TopUser> topUsers;

  _RankingResponse({
    required this.year,
    required this.month,
    required this.topUsers,
  });

  factory _RankingResponse.fromJson(Map<String, dynamic> j) {
    final year = (j['year'] is num) ? (j['year'] as num).toInt() : 0;
    final month = (j['month'] is num) ? (j['month'] as num).toInt() : 0;

    final raw = j['topUsers'];
    final list = (raw is List) ? raw : const <dynamic>[];

    final users = list
        .whereType<Map>()
        .map((e) => _TopUser.fromJson(e.cast<String, dynamic>()))
        .toList();

    return _RankingResponse(year: year, month: month, topUsers: users);
  }
}

class _TopUser {
  final String userId;
  final String userName;
  final double totalDistanceKm;

  _TopUser({
    required this.userId,
    required this.userName,
    required this.totalDistanceKm,
  });

  factory _TopUser.fromJson(Map<String, dynamic> j) {
    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse((v ?? '').toString().replaceAll(',', '.')) ?? 0.0;
    }

    return _TopUser(
      userId: (j['userId'] ?? '').toString(),
      userName: (j['userName'] ?? 'Użytkownik').toString(),
      totalDistanceKm: parseDouble(j['totalDistanceKm']),
    );
  }
}
