import 'package:dio/dio.dart';
import 'package:mini_strava/core/network/endpoints.dart';

class ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get(Endpoints.profileMe);
    final data = res.data;

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();

    throw Exception('Nieprawidłowa odpowiedź API profile/me: $data');
  }

  Future<void> updateMe({
    required String firstName,
    required String lastName,
    required DateTime? birthDate,
    required String gender,
    required int heightCm,
    required double weightKg,
  }) async {
    await dio.put(
      Endpoints.profileMe,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate?.toUtc().toIso8601String(),
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
      },
    );
  }
}
