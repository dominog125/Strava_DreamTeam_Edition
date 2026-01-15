import '../entities/friend.dart';

abstract class FriendsRepository {
  Future<List<Friend>> getFriends();
  Future<void> deleteFriend(String otherUserId);
}
