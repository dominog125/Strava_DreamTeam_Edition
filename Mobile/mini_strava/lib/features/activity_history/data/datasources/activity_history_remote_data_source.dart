import '../models/activity_details_model.dart';
import '../models/activity_summary_model.dart';

abstract class ActivityHistoryRemoteDataSource {
  Future<List<ActivitySummaryModel>> fetchHistory();
  Future<ActivityDetailsModel> fetchById(String id);
}
