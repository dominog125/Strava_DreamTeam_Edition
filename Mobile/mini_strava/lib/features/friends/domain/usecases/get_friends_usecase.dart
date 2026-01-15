import '../entities/friend.dart';
import '../repositories/friends_repository.dart';

class GetFriendsUseCase {
  final FriendsRepository repo;
  GetFriendsUseCase(this.repo);

  Future<List<Friend>> call() => repo.getFriends();
}
