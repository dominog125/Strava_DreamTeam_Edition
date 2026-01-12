import '../entities/activity_summary.dart';
import '../repositories/activity_history_repository.dart';

class GetActivityHistoryUseCase {
  final ActivityHistoryRepository repo;
  const GetActivityHistoryUseCase(this.repo);

  Future<List<ActivitySummary>> call() => repo.getHistory();
}
