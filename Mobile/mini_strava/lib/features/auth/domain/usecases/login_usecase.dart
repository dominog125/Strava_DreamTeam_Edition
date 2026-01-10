import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repo;
  LoginUseCase(this.repo);

  Future<AuthTokens> call({
    required String email,
    required String password,
  }) {
    return repo.login(email: email, password: password);
  }
}

