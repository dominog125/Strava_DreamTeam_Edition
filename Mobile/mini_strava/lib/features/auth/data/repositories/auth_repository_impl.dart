import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
// API HERE: repo impl łączy remote datasource i domain
// TODO(API): Podmieniamy Fake na Impl w injectorze
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);
  // TODO(API): w środku tylko delegacja do remote + mapowanie modeli

  @override
  Future<AuthTokens> login({required String email, required String password}) {
    return remote.login(email, password);
  }
}
