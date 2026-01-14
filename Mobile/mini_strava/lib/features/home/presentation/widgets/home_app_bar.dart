import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenFriends;
  final VoidCallback onOpenInvites;
  final VoidCallback onOpenProfile;
  final String? avatarUrl;
  final String? initials;
  final int? invitesCount;

  const HomeAppBar({
    super.key,
    required this.onOpenFriends,
    required this.onOpenInvites,
    required this.onOpenProfile,
    this.avatarUrl,
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

    return AppBar(
      backgroundColor: barColor,
      centerTitle: false,
      titleSpacing: 12,


      title: SizedBox(
        height: 28,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),

      actions: [
        IconButton(
          tooltip: 'Znajomi',
          onPressed: onOpenFriends,
          icon: const Icon(Icons.group_outlined),
        ),
        _IconWithBadge(
          tooltip: 'Zaproszenia',
          onPressed: onOpenInvites,
          icon: Icons.mail_outline,
          count: invitesCount,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _AvatarButton(
            avatarUrl: avatarUrl,
            initials: initials,
            onTap: onOpenProfile,
          ),
        ),
      ],
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final int? count;

  const _IconWithBadge({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final bool show = count != null;
    final bool showNumber = (count ?? 0) > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon),
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

class _AvatarButton extends StatelessWidget {
  final String? avatarUrl;
  final String? initials;
  final VoidCallback onTap;

  const _AvatarButton({
    required this.avatarUrl,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String fallback =
    (initials == null || initials!.trim().isEmpty)
        ? 'U'
        : initials!.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: CircleAvatar(
        radius: 18,
        backgroundColor:
        Theme.of(context).colorScheme.onPrimary.withAlpha(40),
        foregroundColor: Colors.white,
        backgroundImage:
        (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
            ? NetworkImage(avatarUrl!)
            : null,
        child: (avatarUrl == null || avatarUrl!.trim().isEmpty)
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
