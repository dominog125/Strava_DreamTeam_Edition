enum ActivityType { run, bike, walk }

class Activity {
  final String id;
  final ActivityType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;

  const Activity({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
  });
}