import 'package:hive/hive.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokensModel tokens);
  AuthTokensModel? getTokens();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<AuthTokensModel> box;
  static const _key = 'tokens';

  AuthLocalDataSourceImpl(this.box);

  @override
  Future<void> saveTokens(AuthTokensModel tokens) => box.put(_key, tokens);

  @override
  AuthTokensModel? getTokens() => box.get(_key);

  @override
  Future<void> clear() => box.delete(_key);
}
