import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  // internet
  bool _checkingInternet = true;
  bool _hasInternet = false;

  // api + state listy
  late final Dio _dio;
  bool _loadingList = false;
  String? _error;
  List<_UserSearchItem> _users = [];

  // cooldown (2h) dla zaproszen
  late final SharedPreferences _prefs;
  final Map<String, int> _inviteCooldownUntilMs = {}; // userName -> epoch ms
  final Set<String> _sendingInvites = {}; // userName
  static const int _take = 20;
  static const Duration _cooldown = Duration(hours: 2);
  static const String _cooldownPrefsKey = 'invite_cooldowns_v1';

  // blokowanie (lokalny stan ikony)
  static const String _blockedPrefsKey = 'blocked_users_v1'; // userId -> bool
  final Map<String, bool> _blockedByUserId = {};
  final Set<String> _processingLock = {}; // userId

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;
    _prefs = sl<SharedPreferences>();

    _loadCooldowns();
    _loadBlocked();

    _checkInternet().then((_) {
      if (_hasInternet) {
        _fetchUsers(query: null); // ✅ po wejściu pokazujemy wszystkich
      }
    });

    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  // ---------------- RELATION STATUS ----------------
  // accepted/friend => traktujemy jak "znajomy" (koperta znika)
  bool _isFriend(String relationStatus) {
    final s = relationStatus.trim().toLowerCase();
    return s.contains('accept') || s.contains('friend');
  }

  // ---------------- COOLDOWN ----------------
  void _loadCooldowns() {
    try {
      final raw = _prefs.getString(_cooldownPrefsKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      _inviteCooldownUntilMs.clear();
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        if (val is int) _inviteCooldownUntilMs[key] = val;
      }
      _cleanupExpiredCooldowns();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _saveCooldowns() async {
    _cleanupExpiredCooldowns();
    final raw = jsonEncode(_inviteCooldownUntilMs);
    await _prefs.setString(_cooldownPrefsKey, raw);
  }

  void _cleanupExpiredCooldowns() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _inviteCooldownUntilMs.removeWhere((_, untilMs) => untilMs <= now);
  }

  bool _isInviteBlocked(String userName) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final until = _inviteCooldownUntilMs[userName] ?? 0;
    return until > now;
  }

  Duration _inviteRemaining(String userName) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final until = _inviteCooldownUntilMs[userName] ?? 0;
    final diffMs = until - now;
    if (diffMs <= 0) return Duration.zero;
    return Duration(milliseconds: diffMs);
  }

  String _formatDuration(Duration d) {
    final totalMin = d.inMinutes;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h <= 0) return '$m min';
    return '${h}h ${m}m';
  }

  // ---------------- BLOKOWANIE ----------------

  void _loadBlocked() {
    try {
      final raw = _prefs.getString(_blockedPrefsKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      _blockedByUserId.clear();
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        if (val is bool) _blockedByUserId[key] = val;
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _saveBlocked() async {
    await _prefs.setString(_blockedPrefsKey, jsonEncode(_blockedByUserId));
  }

  bool _isBlocked(String userId) {
    return _blockedByUserId[userId] ?? false;
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Tak'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _toggleBlock({
    required String userId,
    required String userName,
    required bool block, // true => block, false => unblock
  }) async {
    if (_processingLock.contains(userId)) return;

    final confirmed = await _confirmDialog(
      title: block ? 'Zablokować użytkownika?' : 'Odblokować użytkownika?',
      message: block
          ? 'Czy na pewno chcesz zablokować użytkownika $userName?'
          : 'Czy na pewno chcesz odblokować użytkownika $userName?',
    );
    if (!confirmed) return;

    setState(() => _processingLock.add(userId));

    try {
      if (block) {
        await _dio.post(
          '/api/friends/$userId/block',
          options: Options(headers: {'accept': '*/*'}),
        );
        _blockedByUserId[userId] = true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Zablokowano użytkownika $userName')),
          );
        }
      } else {
        await _dio.post(
          '/api/friends/$userId/unblock',
          options: Options(headers: {'accept': '*/*'}),
        );
        _blockedByUserId[userId] = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Odblokowano użytkownika $userName')),
          );
        }
      }

      await _saveBlocked();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              block
                  ? 'Nie udało się zablokować użytkownika'
                  : 'Nie udało się odblokować użytkownika',
            ),
          ),
        );
      }
    } finally {
      _processingLock.remove(userId);
      if (mounted) setState(() {});
    }
  }

  // ---------------- INTERNET ----------------
  bool _hasAnyNetwork(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _checkInternet() async {
    if (!mounted) return;
    setState(() {
      _checkingInternet = true;
      _error = null;
    });

    final results = await Connectivity().checkConnectivity();
    final hasNetwork = _hasAnyNetwork(results);

    bool hasInternet = false;
    if (hasNetwork) {
      try {
        final r = await InternetAddress.lookup('example.com')
            .timeout(const Duration(seconds: 2));
        hasInternet = r.isNotEmpty && r.first.rawAddress.isNotEmpty;
      } catch (_) {
        hasInternet = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _hasInternet = hasInternet;
      _checkingInternet = false;
    });
  }

  // ---------------- SEARCH (DEBOUNCE) ----------------
  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final q = _controller.text.trim();
      if (!_hasInternet) return;
      await _fetchUsers(query: q.isEmpty ? null : q);
    });
  }

  Future<void> _fetchUsers({String? query}) async {
    if (!mounted) return;
    setState(() {
      _loadingList = true;
      _error = null;
    });

    try {
      final params = <String, dynamic>{'take': _take};
      if (query != null && query.isNotEmpty) params['query'] = query;

      final res = await _dio.get(
        '/api/friends/search',
        queryParameters: params,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'accept': 'text/plain'},
        ),
      );

      final data = res.data;
      final decoded = data is String ? jsonDecode(data) : data;

      final list = (decoded as List)
          .map((e) => _UserSearchItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _users = list;
        _loadingList = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingList = false;
        _error = 'Nie udało się pobrać użytkowników';
      });
    }
  }

  // ---------------- INVITE (POST) ----------------
  Future<void> _sendInvite(String userName) async {
    if (_sendingInvites.contains(userName)) return;

    if (_isInviteBlocked(userName)) {
      final left = _inviteRemaining(userName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zaproszenie już wysłane. Spróbuj za ${_formatDuration(left)}.',
          ),
        ),
      );
      return;
    }

    setState(() => _sendingInvites.add(userName));

    try {
      await _dio.post(
        '/api/friends/requests',
        data: {'userName': userName},
        options: Options(headers: {'accept': '*/*'}),
      );

      final until = DateTime.now().add(_cooldown).millisecondsSinceEpoch;
      _inviteCooldownUntilMs[userName] = until;
      await _saveCooldowns();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wysłano zaproszenie do $userName')),
      );

      setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się wysłać zaproszenia')),
      );
    } finally {
      _sendingInvites.remove(userName);
      if (mounted) setState(() {});
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_checkingInternet) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasInternet) {
      return OfflinePlaceholder(
        message: 'Nie załadowano wyszukiwania',
        onRetry: () async {
          await _checkInternet();
          if (_hasInternet) {
            await _fetchUsers(
              query: _controller.text.trim().isEmpty
                  ? null
                  : _controller.text.trim(),
            );
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Szukaj')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withAlpha(160),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outlineVariant.withAlpha(120)),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Szukaj...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
            Expanded(
              child: _loadingList
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('Brak wyników'))
                  : ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final u = _users[i];

                  final isFriend = _isFriend(u.relationStatus);
                  final blockedInviteCooldown = _isInviteBlocked(u.userName);
                  final sendingInvite = _sendingInvites.contains(u.userName);

                  // kłódka zawsze, koperta znika dla accepted/friend
                  const showLock = true;
                  final showInvite = !isFriend;

                  final inviteDisabled =
                      blockedInviteCooldown || sendingInvite;

                  final inviteTooltip = sendingInvite
                      ? 'Wysyłanie...'
                      : (blockedInviteCooldown
                      ? 'Możesz ponowić za ${_formatDuration(_inviteRemaining(u.userName))}'
                      : 'Zaproś');

                  final isBlocked = _isBlocked(u.userId);
                  final lockBusy = _processingLock.contains(u.userId);

                  return _UserRow(
                    userId: u.userId,
                    userName: u.userName,
                    relationStatus: u.relationStatus,
                    showLock: showLock,
                    showInvite: showInvite,
                    inviteDisabled: inviteDisabled,
                    inviteTooltip: inviteTooltip,
                    onInvite: () => _sendInvite(u.userName),
                    isBlocked: isBlocked,
                    lockBusy: lockBusy,
                    onToggleLock: () => _toggleBlock(
                      userId: u.userId,
                      userName: u.userName,
                      block: !isBlocked, // jeśli nie zablokowany -> blokuj
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODEL ----------------
class _UserSearchItem {
  final String userId;
  final String userName;
  final String relationStatus;

  _UserSearchItem({
    required this.userId,
    required this.userName,
    required this.relationStatus,
  });

  factory _UserSearchItem.fromJson(Map<String, dynamic> json) {
    return _UserSearchItem(
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      relationStatus: (json['relationStatus'] ?? '').toString(),
    );
  }
}

// ---------------- ROW ----------------
class _UserRow extends StatelessWidget {
  final String userId;
  final String userName;
  final String relationStatus;

  final VoidCallback onInvite;
  final bool inviteDisabled;
  final String inviteTooltip;

  final bool showLock;
  final bool showInvite;

  final bool isBlocked;
  final bool lockBusy;
  final VoidCallback onToggleLock;

  const _UserRow({
    required this.userId,
    required this.userName,
    required this.relationStatus,
    required this.onInvite,
    required this.inviteDisabled,
    required this.inviteTooltip,
    required this.showLock,
    required this.showInvite,
    required this.isBlocked,
    required this.lockBusy,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(110),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withAlpha(90)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primary.withAlpha(60),
            child: Icon(Icons.person, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          if (showLock)
            IconButton(
              tooltip: isBlocked ? 'Odblokuj' : 'Zablokuj',
              onPressed: lockBusy ? null : onToggleLock,
              icon: Icon(isBlocked ? Icons.lock_open_outlined : Icons.lock_outline),
            ),
          if (showInvite)
            IconButton(
              tooltip: inviteTooltip,
              onPressed: inviteDisabled ? null : onInvite,
              icon: const Icon(Icons.mail_outline),
            ),
        ],
      ),
    );
  }
}
