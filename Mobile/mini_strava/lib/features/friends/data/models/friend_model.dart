import '../../domain/entities/friend.dart';

class FriendModel extends Friend {
  const FriendModel({
    required super.userId,
    required super.userName,
    required super.status,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}
