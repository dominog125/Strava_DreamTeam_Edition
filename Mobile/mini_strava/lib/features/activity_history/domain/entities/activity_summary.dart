import 'activity_type.dart';

class ActivitySummary {
  final String id;
  final DateTime date;
  final ActivityType type;
  final Duration duration;
  final double distanceKm;
  final double paceMinPerKm;
  final double avgSpeedKmH;

  const ActivitySummary({
    required this.id,
    required this.date,
    required this.type,
    required this.duration,
    required this.distanceKm,
    required this.paceMinPerKm,
    required this.avgSpeedKmH,
  });
}
