import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class SaveActivityUseCase {
  final ActivityRepository repo;
  SaveActivityUseCase(this.repo);

  Future<void> call(Activity activity) => repo.save(activity);
}
