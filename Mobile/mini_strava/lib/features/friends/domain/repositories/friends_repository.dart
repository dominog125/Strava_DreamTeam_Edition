import '../entities/friend.dart';

abstract class FriendsRepository {
  Future<List<Friend>> getFriends();
}
