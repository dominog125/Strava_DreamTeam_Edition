import 'package:hive/hive.dart';

part 'auth_user_model.g.dart';

@HiveType(typeId: 2)
class AuthUserModel extends HiveObject {
  @HiveField(0)
  final String login;

  @HiveField(1)
  final String password;

  AuthUserModel({
    required this.login,
    required this.password,
  });
}
