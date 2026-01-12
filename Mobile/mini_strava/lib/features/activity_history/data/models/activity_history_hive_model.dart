import 'package:hive/hive.dart';

part 'activity_history_hive_model.g.dart';

@HiveType(typeId: 33)
enum SyncStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  synced,
  @HiveField(2)
  failed,
}

@HiveType(typeId: 34)
class ActivityHistoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String dateIso;

  /// "run" | "bike" | "walk"
  @HiveField(2)
  final String type;

  @HiveField(3)
  final int durationSeconds;

  @HiveField(4)
  final double distanceKm;

  @HiveField(5)
  final double paceMinPerKm;

  @HiveField(6)
  final double avgSpeedKmH;

  @HiveField(7)
  final SyncStatus syncStatus;

  @HiveField(8)
  final String createdAtIso;

  @HiveField(9)
  final String updatedAtIso;

  ActivityHistoryHiveModel({
    required this.id,
    required this.dateIso,
    required this.type,
    required this.durationSeconds,
    required this.distanceKm,
    required this.paceMinPerKm,
    required this.avgSpeedKmH,
    required this.syncStatus,
    required this.createdAtIso,
    required this.updatedAtIso,
  });

  ActivityHistoryHiveModel copyWith({
    SyncStatus? syncStatus,
    String? updatedAtIso,
  }) {
    return ActivityHistoryHiveModel(
      id: id,
      dateIso: dateIso,
      type: type,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      paceMinPerKm: paceMinPerKm,
      avgSpeedKmH: avgSpeedKmH,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAtIso: createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
    );
  }
}
