import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/core/network/api_client.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';

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

  static const int _take = 20;

  @override
  void initState() {
    super.initState();

    // ✅ bierzemy Dio z ApiClient (tak macie w injectorze)
    _dio = sl<ApiClient>().dio;

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

      dynamic decoded;
      if (data is String) {
        decoded = jsonDecode(data);
      } else {
        decoded = data;
      }

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

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_checkingInternet) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ placeholder tylko przy braku internetu
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
      appBar: AppBar(
        title: const Text('Szukaj'),
      ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: TextStyle(color: cs.error),
                ),
              ),
            Expanded(
              child: _loadingList
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('Brak wyników'))
                  : ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final u = _users[i];
                  return _UserRow(
                    userName: u.userName,
                    relationStatus: u.relationStatus,
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

// ---------------- ROW (jak na screenie) ----------------

class _UserRow extends StatelessWidget {
  final String userName;
  final String relationStatus;

  const _UserRow({
    required this.userName,
    required this.relationStatus,
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
          IconButton(
            tooltip: 'Zablokuj (wkrótce)',
            onPressed: () {}, // żeby nie było wyszarzone
            icon: const Icon(Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Zaproś (wkrótce)',
            onPressed: () {}, // koperta zamiast kosza
            icon: const Icon(Icons.mail_outline),
          ),
        ],
      ),
    );
  }
}
