import 'package:dio/dio.dart';
import 'endpoints.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
    // API HERE: baseUrl
    baseUrl: Endpoints.baseUrl,

    // API HERE: timeouty / nagłówki
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )) {
    // TODO(API): opcjonalnie interceptory (token, logi, refresh)
    // API HERE: interceptory
    // dio.interceptors.add(...);
  }
}
