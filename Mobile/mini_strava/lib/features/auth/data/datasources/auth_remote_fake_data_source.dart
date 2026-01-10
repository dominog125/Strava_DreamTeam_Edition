import '../../domain/entities/auth_tokens.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteFakeDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final e = email.trim();

    if (e == 'admin@example.com' && password == '12345678') {
      return const AuthTokens(
        accessToken: 'fake_access',
        refreshToken: 'fake_refresh',
      );
    }

    throw Exception('Invalid credentials');
  }
}
