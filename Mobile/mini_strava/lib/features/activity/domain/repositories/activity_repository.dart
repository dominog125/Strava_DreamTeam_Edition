import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<void> save(Activity activity);
}
