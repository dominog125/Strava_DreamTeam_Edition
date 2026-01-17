import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';
import 'package:mini_strava/features/activity_history/domain/entities/activity_type.dart';
import 'package:mini_strava/features/profile/presentation/controller/profile_controller.dart';

import '../widgets/home_app_bar.dart';
import 'act_ogr_friend_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenInvites;
  final VoidCallback? onOpenRanking;
  final VoidCallback? onOpenSearch;

  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    this.onOpenFriends,
    this.onOpenInvites,
    this.onOpenRanking,
    this.onOpenSearch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== Profile =====
  late final ProfileController _profile;
  Uint8List? _avatarBytes;
  String? _initials;

  // ===== Friends feed =====
  late final Dio _dio;
  bool _feedLoading = true;
  bool _feedOffline = false;
  String? _feedError;
  final int _take = 50;
  List<_FeedItem> _feed = const [];

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;

    _profile = ProfileController();
    _profile.addListener(_syncFromProfile);
    _profile.load();

    _loadFeed();
  }

  void _syncFromProfile() {
    final fn = _profile.firstName.text.trim();
    final ln = _profile.lastName.text.trim();
    final initials =
    ((fn.isNotEmpty ? fn[0] : '') + (ln.isNotEmpty ? ln[0] : '')).trim();
    if (!mounted) return;
    setState(() {
      _avatarBytes = _profile.avatarBytes;
      _initials = initials.isEmpty ? 'U' : initials.toUpperCase();
    });
  }

  @override
  void dispose() {
    _profile.removeListener(_syncFromProfile);
    _profile.disposeControllers();
    super.dispose();
  }

  Future<void> _openProfileAndRefresh() async {
    await Navigator.pushNamed(context, '/profile');
    if (!mounted) return;
    await _profile.load();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _feedLoading = true;
      _feedOffline = false;
      _feedError = null;
    });

    try {
      final res = await _dio.get(
        '/api/friends/feed',
        queryParameters: {'take': _take},
        options: Options(
          responseType: ResponseType.plain,
          headers: {'accept': 'text/plain'},
        ),
      );

      final data = res.data;
      final decoded = data is String ? jsonDecode(data) : data;
      final list = (decoded is List) ? decoded : const <dynamic>[];

      final items = list
          .whereType<Map>()
          .map((e) => _FeedItem.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _feed = items;
        _feedLoading = false;
      });
    } on DioException catch (e) {
      final isOffline = e.error is SocketException ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout;
      if (!mounted) return;
      setState(() {
        _feedOffline = isOffline;
        _feedError = isOffline ? null : 'Nie udało się pobrać listy znajomych';
        _feedLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedError = 'Nie udało się pobrać listy znajomych';
        _feedLoading = false;
      });
    }
  }

  Future<void> _openFriendActivityDetails(_FeedItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActOgrFriendDetailsScreen(
          id: item.id,
          otherUserId: item.authorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onOpenRanking: widget.onOpenRanking ?? () {},
        onOpenFriends: widget.onOpenFriends ?? () {},
        onOpenInvites: widget.onOpenInvites ?? () {},
        onOpenSearch: widget.onOpenSearch ?? () {},
        onOpenProfile: _openProfileAndRefresh,
        avatarBytes: _avatarBytes,
        initials: _initials,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _feedLoading ? null : _loadFeed,
        backgroundColor: const Color(0xFF7A3E1B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.refresh),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Lista treningów znajomych',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_feedOffline)
              const Expanded(child: OfflinePlaceholder())
            else if (_feedLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_feedError != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_feedError!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadFeed,
                            child: const Text('Spróbuj ponownie'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadFeed,
                    child: _feed.isEmpty
                        ? ListView(
                      children: const [
                        SizedBox(height: 24),
                        Center(child: Text('Brak aktywności do wyświetlenia')),
                      ],
                    )
                        : ListView.builder(
                      itemCount: _feed.length,
                      itemBuilder: (context, index) {
                        final item = _feed[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FeedCard(
                            item: item,
                            onTap: () => _openFriendActivityDetails(item),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}



class _FeedItem {
  final String id;
  final String name;
  final String authorId;
  final String authorName;
  final String categoryName;
  final DateTime createdAt;

  _FeedItem({
    required this.id,
    required this.name,
    required this.authorId,
    required this.authorName,
    required this.categoryName,
    required this.createdAt,
  });

  static String _pickAuthor(Map<String, dynamic> j) {

    final s = (j['authorUserName'] ?? '').toString().trim();
    return s.isNotEmpty ? s : 'Użytkownik';
  }

  static DateTime _parseDate(dynamic v) {
    final s = (v ?? '').toString().trim();
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory _FeedItem.fromJson(Map<String, dynamic> j) => _FeedItem(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    authorId: (j['authorId'] ?? '').toString(),
    authorName: _pickAuthor(j),
    categoryName: (j['categoryName'] ?? '').toString(),
    createdAt: _parseDate(j['createdAt']),
  );

  ActivityType get type {
    final s = categoryName.trim().toLowerCase();
    if (s.contains('bieg') || s.contains('run')) return ActivityType.run;
    if (s.contains('rower') || s.contains('bike')) return ActivityType.bike;
    if (s.contains('hiking') || s.contains('spacer') || s.contains('walk')) {
      return ActivityType.walk;
    }
    return ActivityType.unknown;
  }
}

// ==================== UI ====================

class _FeedCard extends StatelessWidget {
  final _FeedItem item;
  final VoidCallback? onTap;

  const _FeedCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = item.createdAt;
    final date = DateFormat('dd.MM.yyyy').format(dt);
    final time = DateFormat('HH:mm').format(dt);

    final icon = _iconFor(item.type);
    final iconColor = _colorFor(item.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2430),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$date $time',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Użytkownik ${item.authorName} wykonał aktywność',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name.trim().isEmpty ? '-' : item.name.trim(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ActivityType t) {
    switch (t) {
      case ActivityType.run:
        return Icons.directions_run;
      case ActivityType.bike:
        return Icons.directions_bike;
      case ActivityType.walk:
        return Icons.directions_walk;
      case ActivityType.unknown:
        return Icons.help_outline;
    }
  }

  Color _colorFor(ActivityType t) {
    switch (t) {
      case ActivityType.run:
        return Colors.orange;
      case ActivityType.bike:
        return Colors.green;
      case ActivityType.walk:
        return Colors.blue;
      case ActivityType.unknown:
        return Colors.grey;
    }
  }
}
