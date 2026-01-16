import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenFriends;
  final VoidCallback onOpenInvites;
  final VoidCallback onOpenSearch; // ✅ NOWE
  final VoidCallback onOpenProfile;

  final Uint8List? avatarBytes;
  final String? localAvatarPath;
  final String? initials;
  final int? invitesCount;

  const HomeAppBar({
    super.key,
    required this.onOpenRanking,
    required this.onOpenFriends,
    required this.onOpenInvites,
    required this.onOpenSearch, // ✅ NOWE
    required this.onOpenProfile,
    this.avatarBytes,
    this.localAvatarPath,
    this.initials,
    this.invitesCount,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final Color barColor =
        Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.primary;

    // ciaśniejsze IconButtony (żeby weszła dodatkowa lupa i nie było overflow)
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);
    const iconPadding = EdgeInsets.zero;

    return AppBar(
      backgroundColor: barColor,
      centerTitle: false,
      titleSpacing: 8,
      title: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo.png',
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Szukaj',
          onPressed: () {
            debugPrint('SEARCH CLICK');
            onOpenSearch();
          },
          icon: const Icon(Icons.search),
          constraints: iconConstraints,
          padding: iconPadding,
        ),
        IconButton(
          tooltip: 'Ranking użytkowników',
          onPressed: onOpenRanking,
          icon: const Icon(Icons.emoji_events_outlined),
          constraints: iconConstraints,
          padding: iconPadding,
        ),
        IconButton(
          tooltip: 'Znajomi',
          onPressed: onOpenFriends,
          icon: const Icon(Icons.group_outlined),
          constraints: iconConstraints,
          padding: iconPadding,
        ),
        _IconWithBadge(
          tooltip: 'Zaproszenia',
          onPressed: onOpenInvites,
          icon: Icons.mail_outline,
          count: invitesCount,
          constraints: iconConstraints,
          padding: iconPadding,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 4),
          child: _AvatarButton(
            avatarBytes: avatarBytes,
            localAvatarPath: localAvatarPath,
            initials: initials,
            onTap: onOpenProfile,
          ),
        ),
      ],
    );
  }
}

/// ---------- BADGE ----------
class _IconWithBadge extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final int? count;
  final BoxConstraints constraints;
  final EdgeInsets padding;

  const _IconWithBadge({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.count,
    required this.constraints,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final show = count != null;
    final showNumber = (count ?? 0) > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon),
          constraints: constraints,
          padding: padding,
        ),
        if (show)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: showNumber
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                  : EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: showNumber
                  ? Text(
                '${count!.clamp(0, 99)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              )
                  : const SizedBox(width: 10, height: 10),
            ),
          ),
      ],
    );
  }
}

/// ---------- AVATAR ----------
class _AvatarButton extends StatelessWidget {
  final Uint8List? avatarBytes;
  final String? localAvatarPath;
  final String? initials;
  final VoidCallback onTap;

  const _AvatarButton({
    required this.avatarBytes,
    required this.localAvatarPath,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fallback =
    (initials == null || initials!.trim().isEmpty) ? 'U' : initials!.trim();

    ImageProvider? provider;
    final p = (localAvatarPath ?? '').trim();

    if (p.isNotEmpty) {
      provider = FileImage(File(p));
    } else {
      final b = avatarBytes;
      if (b != null && b.isNotEmpty) provider = MemoryImage(b);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white.withAlpha(40),
        foregroundColor: Colors.white,
        backgroundImage: provider,
        child: provider == null
            ? Text(
          fallback.length > 2
              ? fallback.substring(0, 2).toUpperCase()
              : fallback.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        )
            : null,
      ),
    );
  }
}
