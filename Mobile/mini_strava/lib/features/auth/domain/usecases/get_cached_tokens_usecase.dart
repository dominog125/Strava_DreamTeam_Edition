import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class GetCachedTokensUseCase {
  final AuthRepository repo;
  GetCachedTokensUseCase(this.repo);

  Future<AuthTokens?> call() => repo.getCachedTokens();
}