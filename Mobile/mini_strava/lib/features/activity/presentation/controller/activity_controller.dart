import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/activity.dart' as act;
import '../../domain/usecases/save_activity_usecase.dart';
import '../../../activity_history/data/repositories/activity_history_repository_impl.dart';
import '../../../activity_history/domain/entities/activity_type.dart' as hist;
import '../../../activity_history/domain/entities/gps_point.dart';

enum ActivityState { idle, running, paused, finished }

class ActivityController extends ChangeNotifier {
  final SaveActivityUseCase _save = sl<SaveActivityUseCase>();
  final ActivityHistoryRepositoryImpl _history = sl<ActivityHistoryRepositoryImpl>();

  act.ActivityType type = act.ActivityType.run;
  ActivityState state = ActivityState.idle;

  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  DateTime? _lastTick;

  Duration get elapsed => _elapsed;
  DateTime? get startedAt => _startedAt;

  void setType(act.ActivityType t) {
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

  hist.ActivityType mapToHistoryType(act.ActivityType t) {
    switch (t) {
      case act.ActivityType.run:
        return hist.ActivityType.run;
      case act.ActivityType.bike:
        return hist.ActivityType.bike;
      case act.ActivityType.walk:
        return hist.ActivityType.walk;
    }
  }

  Future<void> finish(
      BuildContext context, {
        required double distanceKm,
        required List<GpsPoint> track,
        String? routeImagePath,

        String? title,
        String? note,
        String? photoPath,
        hist.ActivityType? overrideType,
      }) async {
    if (state == ActivityState.idle) return;

    final endedAt = DateTime.now();
    final startedAt = _startedAt ?? endedAt;

    final activity = act.Activity(
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

    await _history.addFromActivity(
      date: startedAt,
      type: overrideType ?? mapToHistoryType(type),
      duration: _elapsed,
      distanceKm: distanceKm,
      track: track,
      routeImagePath: routeImagePath,
      title: title,
      note: note,
      photoPath: photoPath,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zapisano aktywność ✅')),
    );

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
