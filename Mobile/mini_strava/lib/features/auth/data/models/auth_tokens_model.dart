import 'package:hive/hive.dart';
import '../../domain/entities/auth_tokens.dart';

part 'auth_tokens_model.g.dart';

@HiveType(typeId: 10)
class AuthTokensModel extends HiveObject {
  @HiveField(0)
  final String accessToken;

  @HiveField(1)
  final String refreshToken;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromEntity(AuthTokens t) => AuthTokensModel(
    accessToken: t.accessToken,
    refreshToken: t.refreshToken,
  );

  AuthTokens toEntity() => AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}

