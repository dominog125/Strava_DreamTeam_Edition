import '../models/activity_model.dart';
import 'package:hive/hive.dart';


abstract class ActivityLocalDataSource {
  Future<void> save(ActivityModel model);
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final Box<ActivityModel> box;

  ActivityLocalDataSourceImpl(this.box);

  @override
  Future<void> save(ActivityModel model) async {
    await box.put(model.id, model);
  }
}

