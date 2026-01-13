import '../entities/activity_details.dart';
import '../entities/activity_summary.dart';

abstract class ActivityHistoryRepository {
  Future<List<ActivitySummary>> getHistory();
  Future<ActivityDetails> getById(String id);
  Future<void> updateMeta({
    required String id,
    String? title,
    String? note,
    String? photoPath,
    bool clearTitle,
    bool clearNote,
    bool clearPhoto,
  });
}
