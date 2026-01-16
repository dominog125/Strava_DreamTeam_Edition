import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';

class InvitesInboxScreen extends StatefulWidget {
  const InvitesInboxScreen({super.key});

  @override
  State<InvitesInboxScreen> createState() => _InvitesInboxScreenState();
}

class _InvitesInboxScreenState extends State<InvitesInboxScreen> {
  // internet
  bool _checkingInternet = true;
  bool _hasInternet = false;

  // api
  late final Dio _dio;
  bool _loading = false;
  String? _error;

  final List<_IncomingInvite> _invites = [];
  final Set<String> _processing = {}; // blokuje wielokrotne kliknięcia

  @override
  void initState() {
    super.initState();
    _dio = sl<ApiClient>().dio;

    _checkInternet().then((_) {
      if (_hasInternet) {
        _fetchIncoming();
      }
    });
  }

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

  Future<void> _fetchIncoming() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get(
        '/api/friends/requests/incoming',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'accept': 'text/plain'},
        ),
      );

      final decoded =
      res.data is String ? jsonDecode(res.data) : res.data;

      final list = (decoded as List)
          .map((e) => _IncomingInvite.fromJson(e))
          .toList();

      if (!mounted) return;
      setState(() {
        _invites
          ..clear()
          ..addAll(list);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Nie udało się pobrać zaproszeń';
      });
    }
  }

  // ================= ACTIONS =================

  Future<void> _acceptInvite(_IncomingInvite invite) async {
    if (_processing.contains(invite.userId)) return;
    setState(() => _processing.add(invite.userId));

    try {
      await _dio.post(
        '/api/friends/requests/${invite.userId}/accept',
        options: Options(headers: {'accept': '*/*'}),
      );

      _invites.removeWhere((e) => e.userId == invite.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zaakceptowano zaproszenie od ${invite.userName}'),
          ),
        );
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd przy akceptacji zaproszenia')),
        );
      }
    } finally {
      _processing.remove(invite.userId);
      if (mounted) setState(() {});
    }
  }

  Future<void> _cancelInvite(_IncomingInvite invite) async {
    if (_processing.contains(invite.userId)) return;
    setState(() => _processing.add(invite.userId));

    try {
      // ✅ FINALNY endpoint zgodny ze swaggerem
      await _dio.delete(
        '/api/friends/requests/${invite.userId}',
        options: Options(headers: {'accept': '*/*'}),
      );

      _invites.removeWhere((e) => e.userId == invite.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odrzucono zaproszenie od ${invite.userName}'),
          ),
        );
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd przy odrzucaniu zaproszenia')),
        );
      }
    } finally {
      _processing.remove(invite.userId);
      if (mounted) setState(() {});
    }
  }

  // ================= UI =================

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
        message: 'Nie załadowano zaproszeń',
        onRetry: () async {
          await _checkInternet();
          if (_hasInternet) {
            await _fetchIncoming();
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zaproszenia')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _invites.isEmpty
                  ? const Center(child: Text('Brak zaproszeń'))
                  : ListView.separated(
                itemCount: _invites.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final inv = _invites[i];
                  final busy =
                  _processing.contains(inv.userId);

                  return _InviteRow(
                    invite: inv,
                    busy: busy,
                    onAccept: () => _acceptInvite(inv),
                    onReject: () => _cancelInvite(inv),
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

// ================= MODEL =================

class _IncomingInvite {
  final String userId;
  final String userName;

  _IncomingInvite({
    required this.userId,
    required this.userName,
  });

  factory _IncomingInvite.fromJson(Map<String, dynamic> json) {
    return _IncomingInvite(
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
    );
  }
}

// ================= ROW =================

class _InviteRow extends StatelessWidget {
  final _IncomingInvite invite;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InviteRow({
    required this.invite,
    required this.busy,
    required this.onAccept,
    required this.onReject,
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
              'Użytkownik ${invite.userName} chce wysłać Ci zaproszenie do znajomych',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Akceptuj',
            onPressed: busy ? null : onAccept,
            icon: const Icon(Icons.check_circle_outline),
          ),
          IconButton(
            tooltip: 'Odrzuć',
            onPressed: busy ? null : onReject,
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}
