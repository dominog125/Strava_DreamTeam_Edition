import 'package:flutter/material.dart';
import 'package:mini_strava/core/di/injector.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/get_friends_usecase.dart';

class FriendsController extends ChangeNotifier {
  final GetFriendsUseCase _getFriends = sl<GetFriendsUseCase>();

  bool _loading = false;
  bool get isLoading => _loading;

  List<Friend> friends = const [];

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      friends = await _getFriends();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
