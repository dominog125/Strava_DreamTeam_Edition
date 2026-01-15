import '../repositories/friends_repository.dart';

class DeleteFriendUseCase {
  final FriendsRepository repo;
  DeleteFriendUseCase(this.repo);

  Future<void> call(String otherUserId) => repo.deleteFriend(otherUserId);
}
