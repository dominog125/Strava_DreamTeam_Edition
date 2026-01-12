import 'package:hive/hive.dart';
import '../models/activity_history_hive_model.dart';
import 'activity_history_local_data_source.dart';

class ActivityHistoryLocalDataSourceImpl implements ActivityHistoryLocalDataSource {
  final Box<ActivityHistoryHiveModel> box;
  ActivityHistoryLocalDataSourceImpl(this.box);

  @override
  Future<List<ActivityHistoryHiveModel>> getAll() async {
    final items = box.values.toList();
    // sort: newest first
    items.sort((a, b) => b.dateIso.compareTo(a.dateIso));
    return items;
  }

  @override
  Future<void> upsert(ActivityHistoryHiveModel item) async {
    await box.put(item.id, item);
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }

  @override
  Future<List<ActivityHistoryHiveModel>> getPending() async {
    return box.values.where((e) => e.syncStatus == SyncStatus.pending).toList();
  }

  @override
  Future<void> markSynced(String id) async {
    final cur = box.get(id);
    if (cur == null) return;
    await box.put(
      id,
      cur.copyWith(
        syncStatus: SyncStatus.synced,
        updatedAtIso: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Future<void> markFailed(String id) async {
    final cur = box.get(id);
    if (cur == null) return;
    await box.put(
      id,
      cur.copyWith(
        syncStatus: SyncStatus.failed,
        updatedAtIso: DateTime.now().toIso8601String(),
      ),
    );
  }
}
