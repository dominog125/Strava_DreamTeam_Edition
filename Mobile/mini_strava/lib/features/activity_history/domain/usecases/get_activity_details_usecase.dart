import '../entities/activity_details.dart';
import '../repositories/activity_history_repository.dart';

class GetActivityDetailsUseCase {
  final ActivityHistoryRepository repo;
  const GetActivityDetailsUseCase(this.repo);

  Future<ActivityDetails> call(String id) => repo.getById(id);
}
