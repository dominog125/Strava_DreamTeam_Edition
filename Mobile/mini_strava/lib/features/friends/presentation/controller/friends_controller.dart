import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';

import '../../domain/entities/friend.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/delete_friend_usecase.dart';

class FriendsController extends ChangeNotifier {
  final GetFriendsUseCase _getFriends = sl<GetFriendsUseCase>();
  final DeleteFriendUseCase _deleteFriend = sl<DeleteFriendUseCase>();

  bool _loading = false;
  bool get isLoading => _loading;

  List<Friend> _friends = const [];
  List<Friend> get friends => _friends;


  Future<void> load() async {
    if (_loading) return;

    _setLoading(true);
    try {
      _friends = await _getFriends();
    } catch (_) {
      _friends = const [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFriend(String otherUserId) async {
    if (_loading) return;

    _setLoading(true);
    try {
      await _deleteFriend(otherUserId);


      _friends = _friends
          .where((f) => f.userId != otherUserId)
          .toList(growable: false);
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
