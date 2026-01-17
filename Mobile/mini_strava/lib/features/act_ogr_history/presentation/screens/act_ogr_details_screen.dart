import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';

class ActOgrDetailsScreen extends StatefulWidget {
  final String id;
  const ActOgrDetailsScreen({super.key, required this.id});

  @override
  State<ActOgrDetailsScreen> createState() => _ActOgrDetailsScreenState();
}

class _ActOgrDetailsScreenState extends State<ActOgrDetailsScreen> {
  late final Dio _dio;

  bool _loading = true;
  bool _saving = false;
  String? _error;


  ActivityType _type = ActivityType.unknown;
  DateTime? _date;
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();


  int _activeSeconds = 0;
  double _distanceKm = 0;
  double _paceMinPerKm = 0;
  double _speedKmH = 0;


  String? _usePhotoPath;
  bool _markDeleteUsePhoto = false;
  Uint8List? _usePhotoBytes;
  Uint8List? _mapPhotoBytes;


  bool _categoriesLoaded = false;
  final Map<ActivityType, String> _categoryIdByType = {};
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
    _titleCtrl.dispose();
    _noteCtrl.dispose();
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
      await _loadActivity();
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

      _categoryIdByType.clear();
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

        if (t != null) {
          _categoryIdByType[t] = id;
          _typeByCategoryId[id] = t;
        }
      }

      _categoriesLoaded = true;
    } catch (_) {
      _categoriesLoaded = false;
    }
  }

  Future<void> _loadActivity() async {
    final res = await _dio.get(
      '/api/Activities/${widget.id}',
      options: Options(headers: {'accept': 'text/plain'}),
    );

    final d = res.data;
    _titleCtrl.text = (d['name'] ?? '').toString();
    _noteCtrl.text = (d['description'] ?? '').toString();
    _distanceKm = (d['lengthInKm'] ?? 0).toDouble();
    _activeSeconds = (d['activeSeconds'] ?? 0).toInt();
    _paceMinPerKm = (d['paceMinPerKm'] ?? 0).toDouble();
    _speedKmH = (d['speedKmPerHour'] ?? 0).toDouble();
    _date = DateTime.tryParse(d['createdAt']?.toString() ?? '');

    final catId = (d['activityCategoryId'] ?? '').toString().trim();
    if (catId.isNotEmpty && _typeByCategoryId.containsKey(catId)) {
      _type = _typeByCategoryId[catId] ?? ActivityType.unknown;
    } else {
      _type = _mapCategoryToType(d['categoryName']?.toString());
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


  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      // PUT META
      await _dio.put(
        '/api/Activities/${widget.id}',
        data: {
          'name': _titleCtrl.text.trim(),
          'description': _noteCtrl.text.trim(),
          'activityCategoryId': _mapTypeToCategoryId(_type),
        },
      );


      if (_markDeleteUsePhoto) {
        await _dio.delete('/api/Activities/${widget.id}/photos/use');
      }


      if (_usePhotoPath != null && !_markDeleteUsePhoto) {
        final form = FormData.fromMap({
          'UsePhoto': await MultipartFile.fromFile(
            _usePhotoPath!,
            filename: _usePhotoPath!.split('/').last,
          ),
        });
        await _dio.post(
          '/api/Activities/${widget.id}/photos',
          data: form,
          options: Options(headers: {'accept': '*/*'}),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się zapisać')),
      );
    }
  }


  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);

    try {
      if (_likedByMe) {
        await _dio.put('/api/activities/${widget.id}/likes');
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

  Future<void> _pickUsePhoto() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;
      setState(() {
        _usePhotoPath = x.path;
        _markDeleteUsePhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać zdjęcia: $e')),
      );
    }
  }

  void _markDeletePhoto() {
    setState(() {
      _usePhotoPath = null;
      _usePhotoBytes = null;
      _markDeleteUsePhoto = true;
    });
  }


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

  String _mapTypeToCategoryId(ActivityType t) {

    if (_categoriesLoaded && _categoryIdByType.containsKey(t)) {
      return _categoryIdByType[t]!;
    }

    switch (t) {
      case ActivityType.run:
        return '11111111-1111-1111-1111-111111111111';
      case ActivityType.bike:
        return '22222222-2222-2222-2222-222222222222';
      case ActivityType.walk:
        return '33333333-3333-3333-3333-333333333333';
      case ActivityType.unknown:
        return '44444444-4444-4444-4444-444444444444';
    }
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
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
      appBar: AppBar(
        title: const Text('Szczegóły aktywności'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
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

          DropdownButtonFormField<ActivityType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Typ aktywności',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: ActivityType.unknown, child: Text('Nie podano')),
              DropdownMenuItem(value: ActivityType.run, child: Text('Bieg')),
              DropdownMenuItem(value: ActivityType.bike, child: Text('Rower')),
              DropdownMenuItem(value: ActivityType.walk, child: Text('Spacer')),
            ],
            onChanged: (v) => setState(() => _type = v ?? ActivityType.unknown),
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


          _UsePhotoCard(
            bytes: _usePhotoBytes,
            localPath: _usePhotoPath,
            onPick: _pickUsePhoto,
            onDelete: _markDeletePhoto,
          ),
          const SizedBox(height: 16),


          _MapCard(bytes: _mapPhotoBytes),
          const SizedBox(height: 16),


          _StatsCard(
            duration: _formatDuration(_activeSeconds),
            distance: _distanceKm,
            pace: _paceMinPerKm,
            speed: _speedKmH,
          ),
          const SizedBox(height: 16),


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


class _UsePhotoCard extends StatelessWidget {
  final Uint8List? bytes;
  final String? localPath;
  final VoidCallback onPick;
  final VoidCallback onDelete;

  const _UsePhotoCard({
    required this.bytes,
    required this.localPath,
    required this.onPick,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocal = (localPath ?? '').trim().isNotEmpty;
    final hasBytes = bytes != null && bytes!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Zdjęcie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: hasLocal
                  ? Image.file(File(localPath!), fit: BoxFit.cover)
                  : hasBytes
                  ? Image.memory(bytes!, fit: BoxFit.cover)
                  : Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(hasLocal || hasBytes ? 'Zmień zdjęcie' : 'Dodaj zdjęcie'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: (hasLocal || hasBytes) ? onDelete : null,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Usuń zdjęcie',
            ),
          ]),
        ]),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                child: const Center(child: Icon(Icons.map_outlined, size: 48)),
              ),
            ),
          ),
        ]),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Statystyki', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 16, runSpacing: 12, children: [
            _Stat(label: 'Czas', value: duration),
            _Stat(label: 'Dystans', value: '${distance.toStringAsFixed(2)} km'),
            _Stat(label: 'Tempo', value: '${pace.toStringAsFixed(1)} min/km'),
            _Stat(label: 'Śr. prędkość', value: '${speed.toStringAsFixed(1)} km/h'),
          ]),
        ]),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]),
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
    if (s.isNotEmpty) return s;
    return 'Użytkownik';
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ]),
      ),
    );
  }
}
