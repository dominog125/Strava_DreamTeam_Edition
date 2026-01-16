import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mini_strava/core/network/endpoints.dart';
import '../models/friend_model.dart';

class FriendsRemoteDataSource {
  final Dio dio;

  FriendsRemoteDataSource(this.dio);

  Future<List<FriendModel>> getFriends({String? status}) async {
    final res = await dio.get(
      Endpoints.friends,
      queryParameters: status == null ? null : {'status': status}, // ✅ Accepted
      options: Options(
        responseType: ResponseType.plain, // ✅ działa i dla text/plain i json
        headers: {'accept': 'text/plain'},
      ),
    );

    final data = res.data;

    // swagger pokazuje text/plain, więc czasem przychodzi String z JSON-em
    final decoded = data is String ? jsonDecode(data) : data;

    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => FriendModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    throw Exception('Nieprawidłowa odpowiedź API /friends: $decoded');
  }

  Future<void> deleteFriend(String otherUserId) async {
    await dio.delete(
      Endpoints.friendDelete(otherUserId),
      options: Options(headers: {'accept': '*/*'}),
    );
  }
}

