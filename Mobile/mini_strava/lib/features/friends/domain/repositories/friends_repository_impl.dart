import '../../domain/entities/friend.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../data/datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remote;
  FriendsRepositoryImpl(this.remote);

  @override
  Future<List<Friend>> getFriends() async {
    return await remote.getFriends();
  }
  @override
  Future<void> deleteFriend(String otherUserId) async {
    await remote.deleteFriend(otherUserId);
  }
}
