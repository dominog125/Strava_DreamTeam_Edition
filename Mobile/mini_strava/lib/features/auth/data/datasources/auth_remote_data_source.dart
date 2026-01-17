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
      data: {'email': email, 'password': password},
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await dio.post(
      Endpoints.register,
      data: {
        'username': username,
        'password': password,
        'email': email,
        'roles': [],
      },
    );
  }
}
