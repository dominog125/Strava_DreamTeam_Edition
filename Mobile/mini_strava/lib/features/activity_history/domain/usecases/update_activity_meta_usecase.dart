import '../entities/activity_type.dart';
import '../../data/repositories/activity_history_repository_impl.dart';

class UpdateActivityMetaUseCase {
  final ActivityHistoryRepositoryImpl repo;
  UpdateActivityMetaUseCase(this.repo);

  Future<void> call({
    required String id,
    ActivityType? activityType,
    String? title,
    String? note,
    String? photoPath,
    bool clearTitle = false,
    bool clearNote = false,
    bool clearPhoto = false,
    List<List<double>>? track,
    bool clearTrack = false,
    String? routeImagePath,
    bool clearRouteImage = false,
  }) {
    return repo.updateMeta(
      id: id,
      activityType: activityType,
      title: title,
      note: note,
      photoPath: photoPath,
      clearTitle: clearTitle,
      clearNote: clearNote,
      clearPhoto: clearPhoto,
      track: track,
      clearTrack: clearTrack,
      routeImagePath: routeImagePath,
      clearRouteImage: clearRouteImage,
    );
  }
}
