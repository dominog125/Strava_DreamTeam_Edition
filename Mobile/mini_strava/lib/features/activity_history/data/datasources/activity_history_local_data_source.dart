import '../models/activity_history_hive_model.dart';

abstract class ActivityHistoryLocalDataSource {
  Future<List<ActivityHistoryHiveModel>> getAll();
  Future<void> upsert(ActivityHistoryHiveModel item);
  Future<void> delete(String id);


  Future<List<ActivityHistoryHiveModel>> getPending();
  Future<void> markSynced(String id);
  Future<void> markFailed(String id);
}

