import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/activity_type.dart';
import 'activity_type_model.dart';

class ActivitySummaryModel {
  final String id;
  final String dateIso; // ISO string
  final String type; // "run" | "bike" | "walk"
  final int durationSeconds;
  final double distanceKm;
  final double paceMinPerKm;
  final double avgSpeedKmH;

  const ActivitySummaryModel({
    required this.id,
    required this.dateIso,
    required this.type,
    required this.durationSeconds,
    required this.distanceKm,
    required this.paceMinPerKm,
    required this.avgSpeedKmH,
  });

  factory ActivitySummaryModel.fromJson(Map<String, dynamic> json) {
    return ActivitySummaryModel(
      id: json['id'] as String,
      dateIso: json['date'] as String,
      type: json['type'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      paceMinPerKm: (json['paceMinPerKm'] as num).toDouble(),
      avgSpeedKmH: (json['avgSpeedKmH'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': dateIso,
    'type': type,
    'durationSeconds': durationSeconds,
    'distanceKm': distanceKm,
    'paceMinPerKm': paceMinPerKm,
    'avgSpeedKmH': avgSpeedKmH,
  };

  ActivitySummary toEntity() {
    final ActivityType entityType = ActivityTypeModel(type).toEntity();
    return ActivitySummary(
      id: id,
      date: DateTime.parse(dateIso),
      type: entityType,
      duration: Duration(seconds: durationSeconds),
      distanceKm: distanceKm,
      paceMinPerKm: paceMinPerKm,
      avgSpeedKmH: avgSpeedKmH,
    );
  }

  static ActivitySummaryModel fromEntity(ActivitySummary e) {
    return ActivitySummaryModel(
      id: e.id,
      dateIso: e.date.toIso8601String(),
      type: ActivityTypeModel.fromEntity(e.type).value,
      durationSeconds: e.duration.inSeconds,
      distanceKm: e.distanceKm,
      paceMinPerKm: e.paceMinPerKm,
      avgSpeedKmH: e.avgSpeedKmH,
    );
  }
}
