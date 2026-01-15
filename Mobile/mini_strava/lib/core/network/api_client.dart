import 'package:dio/dio.dart';
import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/features/auth/data/datasources/auth_local_data_source.dart';
import 'endpoints.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Content-Type': 'application/json'},
    ),
  ) {
    _addInterceptors();
  }

  void _addInterceptors() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {

          try {
            final local = sl<AuthLocalDataSource>();
            final cached = local.getTokens();
            final token = cached?.accessToken ?? '';
            if (token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            }
          } catch (_) {

          }

          handler.next(options);
        },
      ),
    );
  }
}
