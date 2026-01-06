import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_data_source.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource local;

  ActivityRepositoryImpl(this.local);

  @override
  Future<void> save(Activity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await local.save(model); // ✅ BEZ toJson
  }
}
