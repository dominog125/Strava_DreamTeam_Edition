import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';

// TEMP (no API): Fake repo do testów UI
// TODO(API): gdy API będzie gotowe -> injector.dart podmienia Fake na Impl



class AuthRepositoryFake implements AuthRepository {
  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    // symulacja sieci
    await Future.delayed(const Duration(milliseconds: 500));

    // mega prosta walidacja "na sucho"
    if (!email.contains('@') || password.length < 8) {
      throw Exception('Invalid credentials');
    }

    // udajemy tokeny
    return const AuthTokens(
      accessToken: 'fake_access_token_123',
      refreshToken: 'fake_refresh_token_456',
    );
  }
}
