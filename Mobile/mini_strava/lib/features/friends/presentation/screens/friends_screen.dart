import 'package:flutter/material.dart';
import '../controller/friends_controller.dart';
import '../../domain/entities/friend.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final FriendsController c;

  @override
  void initState() {
    super.initState();
    c = FriendsController();
    c.addListener(_onChanged);
    c.load();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Znajomi')),
      body: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: c.friends.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => FriendTile(friend: c.friends[i]),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final Friend friend;

  const FriendTile({super.key, required this.friend});

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
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.person, size: 24),
              ),
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
            onPressed: () {}, // TODO: podłączysz później
            icon: const Icon(Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Usuń (później)',
            onPressed: () {}, // TODO: podłączysz później
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
