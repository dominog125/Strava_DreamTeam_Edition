import '../../domain/entities/activity_details.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/activity_type.dart';
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
    return ActivityDetails(summary: _toSummaryEntity(found), gpsTrack: const []);
  }


  Future<void> addManual({
    required DateTime date,
    required ActivityType type,
    required Duration duration,
    required double distanceKm,
  }) async {
    final minutes = duration.inSeconds / 60.0;
    final pace = minutes / distanceKm;
    final speed = distanceKm / (minutes / 60.0);

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
    );

    await local.upsert(model);
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
    );
  }

  ActivityType _stringToType(String s) {
    switch (s) {
      case 'run':
        return ActivityType.run;
      case 'bike':
        return ActivityType.bike;
      case 'walk':
      default:
        return ActivityType.walk;
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
    }
  }
}
