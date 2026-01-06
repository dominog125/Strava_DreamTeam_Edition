import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/save_activity_usecase.dart';

enum ActivityState { idle, running, paused, finished }

class ActivityController extends ChangeNotifier {
  final SaveActivityUseCase _save = sl<SaveActivityUseCase>();

  ActivityType type = ActivityType.run;
  ActivityState state = ActivityState.idle;

  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;

  Timer? _timer;
  DateTime? _lastTick;

  Duration get elapsed => _elapsed;

  void setType(ActivityType t) {
    if (state != ActivityState.idle) return;
    type = t;
    notifyListeners();
  }

  void start() {
    if (state != ActivityState.idle) return;
    _startedAt = DateTime.now();
    _elapsed = Duration.zero;
    _lastTick = DateTime.now();
    state = ActivityState.running;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state != ActivityState.running) return;
      final now = DateTime.now();
      final delta = now.difference(_lastTick!);
      _elapsed += delta;
      _lastTick = now;
      notifyListeners();
    });

    notifyListeners();
  }

  void pause() {
    if (state != ActivityState.running) return;
    state = ActivityState.paused;
    notifyListeners();
  }

  void resume() {
    if (state != ActivityState.paused) return;
    state = ActivityState.running;
    _lastTick = DateTime.now();
    notifyListeners();
  }

  Future<void> finish(BuildContext context) async {
    if (state == ActivityState.idle) return;

    final endedAt = DateTime.now();
    final startedAt = _startedAt ?? endedAt;
    final activity = Activity(
      id: endedAt.microsecondsSinceEpoch.toString(),
      type: type,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: _elapsed,
    );

    state = ActivityState.finished;
    _timer?.cancel();
    _timer = null;

    await _save(activity);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zapisano aktywność ✅')),
    );

    // reset do kolejnej aktywności
    state = ActivityState.idle;
    _startedAt = null;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
