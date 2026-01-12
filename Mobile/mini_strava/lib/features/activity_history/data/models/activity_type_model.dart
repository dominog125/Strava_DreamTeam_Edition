import '../../domain/entities/activity_type.dart';

class ActivityTypeModel {
  final String value; // "run" | "bike" | "walk"

  const ActivityTypeModel(this.value);

  ActivityType toEntity() {
    switch (value) {
      case 'run':
        return ActivityType.run;
      case 'bike':
        return ActivityType.bike;
      case 'walk':
      default:
        return ActivityType.walk;
    }
  }

  static ActivityTypeModel fromEntity(ActivityType type) {
    switch (type) {
      case ActivityType.run:
        return const ActivityTypeModel('run');
      case ActivityType.bike:
        return const ActivityTypeModel('bike');
      case ActivityType.walk:
        return const ActivityTypeModel('walk');
    }
  }
}
