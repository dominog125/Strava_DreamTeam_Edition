import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  String _readToken(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    throw Exception('Brak tokena w odpowiedzi API: $json');
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final data = await remote.login(email: email, password: password);

    final accessToken = _readToken(data, [
      'jwtToken',
      'jwt_token',
      'accessToken',
      'access_token',
      'token',
      'jwt',
      'access',
    ]);

    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: '',
    );


    await local.saveTokens(AuthTokensModel.fromEntity(tokens));

    return tokens;
  }

  @override
  Future<void> logout() async {
    await local.clear();
  }

  @override
  Future<AuthTokens?> getCachedTokens() async {
    final cached = local.getTokens();
    return cached?.toEntity();
  }
  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await remote.register(username: username, email: email, password: password);
  }
}
