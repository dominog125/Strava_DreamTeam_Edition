import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final tokens = await remote.login(email: email, password: password);
    await local.saveTokens(AuthTokensModel.fromEntity(tokens));
    return tokens;
  }

  @override
  Future<void> logout() => local.clear();

  @override
  Future<AuthTokens?> getCachedTokens() async {
    return local.getTokens()?.toEntity();
  }
}
