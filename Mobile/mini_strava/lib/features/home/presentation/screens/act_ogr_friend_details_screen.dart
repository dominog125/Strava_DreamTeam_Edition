

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';

class ActOgrFriendDetailsScreen extends StatefulWidget {
  final String id;
  final String otherUserId;
  const ActOgrFriendDetailsScreen({
    super.key,
    required this.id,
    required this.otherUserId,
  });

  @override
  State<ActOgrFriendDetailsScreen> createState() =>
      _ActOgrFriendDetailsScreenState();
}

class _ActOgrFriendDetailsScreenState extends State<ActOgrFriendDetailsScreen> {
  late final Dio _dio;

  bool _loading = true;
  String? _error;


  ActivityType _type = ActivityType.unknown;
  DateTime? _date;
  String _title = '';
  String _note = '';


  int _activeSeconds = 0;
  double _distanceKm = 0;
  double _paceMinPerKm = 0;
  double _speedKmH = 0;


  Uint8List? _usePhotoBytes;
  Uint8List? _mapPhotoBytes;


  bool _categoriesLoaded = false;
  final Map<String, ActivityType> _typeByCategoryId = {};


  bool _likedByMe = false;
  int _likesCount = 0;
  bool _likeBusy = false;

  List<_Comment> _comments = [];
  final _commentCtrl = TextEditingController();
  bool _commentBusy = false;

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;
    _loadAll();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }


  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _loadCategories();
      await _loadActivityFromFriendEndpoint();
      await Future.wait([
        _loadUsePhoto(),
        _loadMapPhoto(),
        _loadLikes(),
        _loadComments(),
      ]);
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Nie udało się pobrać danych';
        _loading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final res = await _dio.get(
        '/api/ActivityCategories',
        options: Options(headers: {'accept': 'text/plain'}),
      );
      final data = res.data;
      final list = data is List ? data : <dynamic>[];
      _typeByCategoryId.clear();

      for (final e in list) {
        if (e is! Map) continue;
        final m = e.cast<String, dynamic>();
        final id = (m['id'] ?? '').toString().trim();
        final name = (m['name'] ?? '').toString().trim().toLowerCase();
        if (id.isEmpty) continue;

        ActivityType? t;
        if (name.contains('bieg') || name.contains('run')) t = ActivityType.run;
        if (name.contains('rower') || name.contains('bike')) t = ActivityType.bike;
        if (name.contains('spacer') || name.contains('walk') || name.contains('hiking')) {
          t = ActivityType.walk;
        }
        if (t != null) _typeByCategoryId[id] = t;
      }
      _categoriesLoaded = true;
    } catch (_) {
      _categoriesLoaded = false;
    }
  }

  Future<void> _loadActivityFromFriendEndpoint() async {
    final res = await _dio.get(
      '/api/friends/${widget.otherUserId}/activities',
      options: Options(
        responseType: ResponseType.plain,
        headers: {'accept': 'text/plain'},
      ),
    );

    final data = res.data;
    final decoded = data is String ? jsonDecode(data) : data;
    final list = (decoded is List) ? decoded : const <dynamic>[];

    final match = list
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .firstWhere(
          (m) => (m['id'] ?? '').toString() == widget.id,
      orElse: () => <String, dynamic>{},
    );

    if (match.isEmpty) {
      throw Exception('Activity not found');
    }

    _title = (match['name'] ?? '').toString();
    _note = (match['description'] ?? '').toString();
    _distanceKm = (match['lengthInKm'] ?? 0).toDouble();
    _activeSeconds = (match['activeSeconds'] ?? 0).toInt();
    _paceMinPerKm = (match['paceMinPerKm'] ?? 0).toDouble();
    _speedKmH = (match['speedKmPerHour'] ?? 0).toDouble();
    _date = DateTime.tryParse(match['createdAt']?.toString() ?? '');

    final catId = (match['activityCategoryId'] ?? '').toString().trim();
    if (_categoriesLoaded && catId.isNotEmpty && _typeByCategoryId.containsKey(catId)) {
      _type = _typeByCategoryId[catId] ?? ActivityType.unknown;
    } else {
      _type = _mapCategoryToType(match['categoryName']?.toString());
    }
  }

  Future<void> _loadUsePhoto() async {
    try {
      final res = await _dio.get<List<int>>(
        '/api/Activities/${widget.id}/photos/use',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(res.data ?? []);
      _usePhotoBytes = bytes.isEmpty ? null : bytes;
    } catch (_) {
      _usePhotoBytes = null;
    }
  }

  Future<void> _loadMapPhoto() async {
    try {
      final res = await _dio.get<List<int>>(
        '/api/Activities/${widget.id}/photos/map',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(res.data ?? []);
      _mapPhotoBytes = bytes.isEmpty ? null : bytes;
    } catch (_) {
      _mapPhotoBytes = null;
    }
  }

  Future<void> _loadLikes() async {
    final me = await _dio.get<bool>('/api/activities/${widget.id}/likes/me');
    final count = await _dio.get<int>('/api/activities/${widget.id}/likes/count');
    _likedByMe = me.data == true;
    _likesCount = count.data ?? 0;
  }

  Future<void> _loadComments() async {
    final res = await _dio.get<List>('/api/activities/${widget.id}/comments');
    _comments = (res.data ?? [])
        .whereType<Map>()
        .map((e) => _Comment.fromJson(e.cast<String, dynamic>()))
        .toList();
  }


  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);
    try {
      if (_likedByMe) {
        await _dio.delete('/api/activities/${widget.id}/likes');
      } else {
        await _dio.post('/api/activities/${widget.id}/likes');
      }
      await _loadLikes();
      if (!mounted) return;
      setState(() => _likeBusy = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _likeBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się zmienić polubienia')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentBusy) return;
    final txt = _commentCtrl.text.trim();
    if (txt.isEmpty) return;

    setState(() => _commentBusy = true);
    try {
      await _dio.post(
        '/api/activities/${widget.id}/comments',
        data: {'content': txt},
      );
      _commentCtrl.clear();
      await _loadComments();
      if (!mounted) return;
      setState(() => _commentBusy = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _commentBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się dodać komentarza')),
      );
    }
  }

  // ================= HELPERS =================
  ActivityType _mapCategoryToType(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'run':
      case 'bieg':
        return ActivityType.run;
      case 'bike':
      case 'rower':
        return ActivityType.bike;
      case 'walk':
      case 'hiking':
      case 'spacer':
        return ActivityType.walk;
      default:
        return ActivityType.unknown;
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
  }

  String _typeLabel(ActivityType t) {
    switch (t) {
      case ActivityType.run:
        return 'Bieg';
      case ActivityType.bike:
        return 'Rower';
      case ActivityType.walk:
        return 'Spacer';
      case ActivityType.unknown:
        return 'Nie podano';
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły aktywności')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _TypeChip(type: _type, big: true),
          ),
          const SizedBox(height: 10),
          Text(
            _date == null ? '-' : DateFormat('yyyy-MM-dd').format(_date!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),


          _ReadOnlyField(label: 'Typ aktywności', value: _typeLabel(_type)),
          const SizedBox(height: 16),
          _ReadOnlyField(
            label: 'Nazwa aktywności',
            value: _title.trim().isEmpty ? '-' : _title.trim(),
          ),
          const SizedBox(height: 16),
          _ReadOnlyField(
            label: 'Notatka',
            value: _note.trim().isEmpty ? '-' : _note.trim(),
            multiline: true,
          ),
          const SizedBox(height: 16),

          // ===== PHOTO (READ ONLY) =====
          _UsePhotoReadOnlyCard(bytes: _usePhotoBytes),
          const SizedBox(height: 16),

          // ===== MAP =====
          _MapCard(bytes: _mapPhotoBytes),
          const SizedBox(height: 16),

          // ===== STATS =====
          _StatsCard(
            duration: _formatDuration(_activeSeconds),
            distance: _distanceKm,
            pace: _paceMinPerKm,
            speed: _speedKmH,
          ),
          const SizedBox(height: 16),

          // ===== LIKES =====
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: _likedByMe ? Colors.red : null,
                ),
                onPressed: _likeBusy ? null : _toggleLike,
              ),
              Text('$_likesCount'),
            ],
          ),
          const SizedBox(height: 8),


          _CommentsSection(
            comments: _comments,
            controller: _commentCtrl,
            busy: _commentBusy,
            onAdd: _addComment,
          ),
        ],
      ),
    );
  }
}


class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: multiline ? null : 2,
      ),
    );
  }
}

class _UsePhotoReadOnlyCard extends StatelessWidget {
  final Uint8List? bytes;
  const _UsePhotoReadOnlyCard({required this.bytes});

  @override
  Widget build(BuildContext context) {
    final hasBytes = bytes != null && bytes!.isNotEmpty;
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
                child: hasBytes
                    ? Image.memory(bytes!, fit: BoxFit.cover)
                    : Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final Uint8List? bytes;
  const _MapCard({required this.bytes});

  @override
  Widget build(BuildContext context) {
    final has = bytes != null && bytes!.isNotEmpty;
    return Card(
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
                child: has
                    ? Image.memory(bytes!, fit: BoxFit.cover)
                    : Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.map_outlined, size: 48),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String duration;
  final double distance;
  final double pace;
  final double speed;

  const _StatsCard({
    required this.duration,
    required this.distance,
    required this.pace,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
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
                _Stat(label: 'Czas', value: duration),
                _Stat(label: 'Dystans', value: '${distance.toStringAsFixed(2)} km'),
                _Stat(label: 'Tempo', value: '${pace.toStringAsFixed(1)} min/km'),
                _Stat(label: 'Śr. prędkość', value: '${speed.toStringAsFixed(1)} km/h'),
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


class _Comment {
  final String author;
  final String content;
  final DateTime createdAt;

  _Comment({
    required this.author,
    required this.content,
    required this.createdAt,
  });

  static String _pickAuthor(Map<String, dynamic> j) {
    final s = (j['authorUserName'] ?? '').toString().trim();
    return s.isNotEmpty ? s : 'Użytkownik';
  }

  factory _Comment.fromJson(Map<String, dynamic> j) => _Comment(
    author: _pickAuthor(j),
    content: (j['content'] ?? j['text'] ?? j['message'] ?? '').toString(),
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class _CommentsSection extends StatelessWidget {
  final List<_Comment> comments;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final bool busy;

  const _CommentsSection({
    required this.comments,
    required this.controller,
    required this.onAdd,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Komentarze', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (comments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Brak komentarzy'),
              )
            else
              ...comments.map(
                    (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${c.author}: ${c.content}'),
                ),
              ),
            const Divider(),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Dodaj komentarz...'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: busy ? null : onAdd,
                child: busy
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Dodaj'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
