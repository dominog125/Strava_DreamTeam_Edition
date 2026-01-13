import '../entities/activity_type.dart';
import '../../data/repositories/activity_history_repository_impl.dart';

class UpdateActivityMetaUseCase {
  final ActivityHistoryRepositoryImpl repo;
  UpdateActivityMetaUseCase(this.repo);

  Future<void> call({
    required String id,
    ActivityType? type,
    String? title,
    String? note,
    String? photoPath,
    bool clearTitle = false,
    bool clearNote = false,
    bool clearPhoto = false,
  }) {
    return repo.updateMeta(
      id: id,
      type: type,
      title: title,
      note: note,
      photoPath: photoPath,
      clearTitle: clearTitle,
      clearNote: clearNote,
      clearPhoto: clearPhoto,
    );
  }
}
