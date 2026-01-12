import '../entities/activity_details.dart';
import '../entities/activity_summary.dart';

abstract class ActivityHistoryRepository {
  Future<List<ActivitySummary>> getHistory();
  Future<ActivityDetails> getById(String id);
}
