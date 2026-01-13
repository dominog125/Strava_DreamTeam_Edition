import '../../domain/entities/activity_details.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/gps_point.dart';
import '../../domain/repositories/activity_history_repository.dart';
import '../datasources/activity_history_local_data_source.dart';
import '../models/activity_history_hive_model.dart';

class ActivityHistoryRepositoryImpl implements ActivityHistoryRepository {
  final ActivityHistoryLocalDataSource local;

  ActivityHistoryRepositoryImpl(this.local);

  @override
  Future<List<ActivitySummary>> getHistory() async {
    final items = await local.getAll();
    return items.map(_toSummaryEntity).toList();
  }

  @override
  Future<ActivityDetails> getById(String id) async {
    final all = await local.getAll();
    final found = all.firstWhere((e) => e.id == id);

    final gps = (found.track ?? const <List<double>>[])
        .where((p) => p.length >= 2)
        .map((p) => GpsPoint(lat: p[0], lng: p[1]))
        .toList();

    return ActivityDetails(
      summary: _toSummaryEntity(found),
      gpsTrack: gps,
    );
  }

  Future<void> addManual({
    required DateTime date,
    required ActivityType type,
    required Duration duration,
    required double distanceKm,
  }) async {
    final minutes = duration.inSeconds / 60.0;
    final pace = distanceKm > 0 ? (minutes / distanceKm) : 0.0;
    final speed = minutes > 0 ? (distanceKm / (minutes / 60.0)) : 0.0;

    final nowIso = DateTime.now().toIso8601String();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final model = ActivityHistoryHiveModel(
      id: id,
      dateIso: date.toIso8601String(),
      type: _typeToString(type),
      durationSeconds: duration.inSeconds,
      distanceKm: distanceKm,
      paceMinPerKm: pace,
      avgSpeedKmH: speed,
      syncStatus: SyncStatus.pending,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      title: null,
      note: null,
      photoPath: null,
      track: null,
    );

    await local.upsert(model);
  }

  Future<void> addFromActivity({
    required DateTime date,
    required ActivityType type,
    required Duration duration,
    required double distanceKm,
    required List<GpsPoint> track,
  }) async {
    final minutes = duration.inSeconds / 60.0;
    final pace = distanceKm > 0 ? (minutes / distanceKm) : 0.0;
    final speed = minutes > 0 ? (distanceKm / (minutes / 60.0)) : 0.0;

    final nowIso = DateTime.now().toIso8601String();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final model = ActivityHistoryHiveModel(
      id: id,
      dateIso: date.toIso8601String(),
      type: _typeToString(type),
      durationSeconds: duration.inSeconds,
      distanceKm: distanceKm,
      paceMinPerKm: pace,
      avgSpeedKmH: speed,
      syncStatus: SyncStatus.pending,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      title: null,
      note: null,
      photoPath: null,
      track: track.map((p) => [p.lat, p.lng]).toList(),
    );

    await local.upsert(model);
  }

  @override
  Future<void> updateMeta({
    required String id,
    ActivityType? type,
    String? title,
    String? note,
    String? photoPath,
    bool clearTitle = false,
    bool clearNote = false,
    bool clearPhoto = false,
    List<List<double>>? track,
    bool clearTrack = false,
  }) async {
    final all = await local.getAll();
    final found = all.firstWhere((e) => e.id == id);

    final nowIso = DateTime.now().toIso8601String();

    final updated = found.copyWith(
      title: title,
      note: note,
      photoPath: photoPath,
      track: track,
      clearTitle: clearTitle,
      clearNote: clearNote,
      clearPhoto: clearPhoto,
      clearTrack: clearTrack,
      updatedAtIso: nowIso,
      syncStatus: SyncStatus.pending,
    );

    final finalModel = (type == null)
        ? updated
        : ActivityHistoryHiveModel(
      id: updated.id,
      dateIso: updated.dateIso,
      type: _typeToString(type),
      durationSeconds: updated.durationSeconds,
      distanceKm: updated.distanceKm,
      paceMinPerKm: updated.paceMinPerKm,
      avgSpeedKmH: updated.avgSpeedKmH,
      syncStatus: updated.syncStatus,
      createdAtIso: updated.createdAtIso,
      updatedAtIso: updated.updatedAtIso,
      title: updated.title,
      note: updated.note,
      photoPath: updated.photoPath,
      track: updated.track,
    );

    await local.upsert(finalModel);
  }

  ActivitySummary _toSummaryEntity(ActivityHistoryHiveModel m) {
    return ActivitySummary(
      id: m.id,
      date: DateTime.parse(m.dateIso),
      type: _stringToType(m.type),
      duration: Duration(seconds: m.durationSeconds),
      distanceKm: m.distanceKm,
      paceMinPerKm: m.paceMinPerKm,
      avgSpeedKmH: m.avgSpeedKmH,
      title: m.title,
      note: m.note,
      photoPath: m.photoPath,
    );
  }

  ActivityType _stringToType(String s) {
    switch (s) {
      case 'run':
        return ActivityType.run;
      case 'bike':
        return ActivityType.bike;
      case 'walk':
        return ActivityType.walk;
      case 'unknown':
      default:
        return ActivityType.unknown;
    }
  }

  String _typeToString(ActivityType t) {
    switch (t) {
      case ActivityType.run:
        return 'run';
      case ActivityType.bike:
        return 'bike';
      case ActivityType.walk:
        return 'walk';
      case ActivityType.unknown:
        return 'unknown';
    }
  }
}
