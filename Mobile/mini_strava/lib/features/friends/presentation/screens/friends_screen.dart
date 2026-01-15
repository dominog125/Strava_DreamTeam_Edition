import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';

import '../controller/friends_controller.dart';
import '../../domain/entities/friend.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final FriendsController c;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  bool _checkingNet = true;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    c = FriendsController();
    c.addListener(_onChanged);

    _checkInternetAndLoad();

    _connSub = Connectivity().onConnectivityChanged.listen((_) async {
      final ok = await _pingInternet();
      if (!mounted) return;

      final changed = ok != _hasInternet;
      if (changed) {
        setState(() {
          _hasInternet = ok;
          _checkingNet = false;
        });
      }

      if (ok && changed) {
        await c.load();
      }
    });
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _connSub?.cancel();
    c.removeListener(_onChanged);
    super.dispose();
  }

  bool _hasAnyNetwork(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> _pingInternet() async {
    final results = await Connectivity().checkConnectivity();
    final hasNetwork = _hasAnyNetwork(results);
    if (!hasNetwork) return false;

    try {
      final r = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 2));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInternetAndLoad() async {
    if (!mounted) return;
    setState(() => _checkingNet = true);

    final ok = await _pingInternet();

    if (!mounted) return;
    setState(() {
      _hasInternet = ok;
      _checkingNet = false;
    });

    if (ok) {
      await c.load();
    }
  }

  Future<void> _confirmDelete(Friend friend) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń znajomego'),
        content: Text(
          'Czy na pewno chcesz usunąć ${friend.userName.isEmpty ? "tego użytkownika" : friend.userName} z listy znajomych?',
        ),
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
      ),
    );

    if (res != true || !mounted) return;


    final ok = await _pingInternet();
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _hasInternet = false;
        _checkingNet = false;
      });
      return;
    }

    try {
      await c.removeFriend(friend.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usunięto znajomego ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się usunąć: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingNet) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasInternet) {
      return OfflinePlaceholder(
        message: 'Nie załadowano znajomych',
        subtitle: 'Brak połączenia z internetem.',
        onRetry: _checkInternetAndLoad,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Znajomi')),
      body: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: c.friends.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => FriendTile(
          friend: c.friends[i],
          onDelete: () => _confirmDelete(c.friends[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Odśwież',
        onPressed: _checkInternetAndLoad,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback onDelete;

  const FriendTile({
    super.key,
    required this.friend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = friend.isActive ? Colors.green : Colors.grey;
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final tileColor = base.withAlpha((0.35 * 255).round());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: tileColor,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(radius: 22, child: Icon(Icons.person, size: 24)),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.userName.isEmpty ? '(brak nazwy)' : friend.userName,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Zablokuj (później)',
            onPressed: () {}, // TODO
            icon: const Icon(Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Usuń',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
