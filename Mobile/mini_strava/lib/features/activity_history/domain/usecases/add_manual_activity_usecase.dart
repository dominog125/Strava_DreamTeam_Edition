import '../entities/activity_type.dart';
import '../../data/repositories/activity_history_repository_impl.dart';

class AddManualActivityUseCase {
  final ActivityHistoryRepositoryImpl repo;
  AddManualActivityUseCase(this.repo);

  Future<void> call({
    required DateTime date,
    required ActivityType type,
    required Duration duration,
    required double distanceKm,
  }) {
    return repo.addManual(
      date: date,
      type: type,
      duration: duration,
      distanceKm: distanceKm,
    );
  }
}
