import 'package:dio/dio.dart';
import 'package:mini_strava/core/network/endpoints.dart';
import '../models/friend_model.dart';

class FriendsRemoteDataSource {
  final Dio dio;
  FriendsRemoteDataSource(this.dio);

  Future<List<FriendModel>> getFriends() async {
    final res = await dio.get(Endpoints.friends);
    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => FriendModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    throw Exception('Nieprawidłowa odpowiedź API /friends: $data');
  }
}
