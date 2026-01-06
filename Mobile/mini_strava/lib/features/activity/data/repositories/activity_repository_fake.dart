import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';

class ActivityRepositoryFake implements ActivityRepository {
  final List<Activity> _items = [];

  @override
  Future<void> save(Activity activity) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.add(activity);
  }


}
