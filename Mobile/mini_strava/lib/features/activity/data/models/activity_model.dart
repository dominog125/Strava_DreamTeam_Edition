import 'package:hive/hive.dart';
import '../../domain/entities/activity.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 1)
class ActivityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int type;

  @HiveField(2)
  final DateTime startedAt;

  @HiveField(3)
  final DateTime endedAt;

  @HiveField(4)
  final int durationSeconds;

  ActivityModel({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  factory ActivityModel.fromEntity(Activity a) {
    return ActivityModel(
      id: a.id,
      type: a.type.index,
      startedAt: a.startedAt,
      endedAt: a.endedAt,
      durationSeconds: a.duration.inSeconds,
    );
  }
}
