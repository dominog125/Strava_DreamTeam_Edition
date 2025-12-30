import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/auth_tokens_model.dart';
// API HERE: tu będą realne requesty do backendu (Dio)
abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    final Response res = await client.dio.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthTokensModel.fromJson(res.data as Map<String, dynamic>);
  }
}


  // TODO(API): implementacja call do /login
  // Future<AuthTokensModel> login(String email, String password);

  // TODO(API): implementacja call do /register
  // Future<void> register(...);

  // TODO(API): implementacja call do /reset-password
  // Future<void> resetPassword(String email);

