class Friend {
  final String userId;
  final String userName;
  final String status;

  const Friend({
    required this.userId,
    required this.userName,
    required this.status,
  });

  bool get isActive {
    final s = status.trim().toLowerCase();
    return s == 'active' || s == 'online' || s == 'aktywny';
  }
}
