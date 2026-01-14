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

  @HiveField(10)
  final String? title;

  @HiveField(11)
  final String? note;

  @HiveField(12)
  final String? photoPath;

  @HiveField(13)
  final List<List<double>>? track;

  @HiveField(14)
  final String? routeImagePath;

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
    this.title,
    this.note,
    this.photoPath,
    this.track,
    this.routeImagePath,
  });

  ActivityHistoryHiveModel copyWith({
    SyncStatus? syncStatus,
    String? updatedAtIso,
    String? title,
    String? note,
    String? photoPath,
    List<List<double>>? track,
    String? routeImagePath,
    bool clearTitle = false,
    bool clearNote = false,
    bool clearPhoto = false,
    bool clearTrack = false,
    bool clearRouteImage = false,
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
      title: clearTitle ? null : (title ?? this.title),
      note: clearNote ? null : (note ?? this.note),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      track: clearTrack ? null : (track ?? this.track),
      routeImagePath:
      clearRouteImage ? null : (routeImagePath ?? this.routeImagePath),
    );
  }
}
