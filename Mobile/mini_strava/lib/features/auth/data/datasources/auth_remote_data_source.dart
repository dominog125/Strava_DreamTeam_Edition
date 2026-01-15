import 'package:dio/dio.dart';
import 'package:mini_strava/core/network/endpoints.dart';

class AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      Endpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Nieoczekiwana odpowiedź z API: ${res.data}');
  }
}
