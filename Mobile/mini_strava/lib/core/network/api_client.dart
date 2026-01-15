import 'package:dio/dio.dart';
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
          // TODO: pobierz accessToken z cache (Hive/AuthLocalDataSource/AuthSession itp.)
          final token = '';

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // TODO(API): później refresh token (401)
          // if (error.response?.statusCode == 401) { ... }
          handler.next(error);
        },
      ),
    );
  }
}
