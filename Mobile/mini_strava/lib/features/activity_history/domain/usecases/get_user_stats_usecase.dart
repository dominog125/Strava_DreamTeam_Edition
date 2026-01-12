import '../entities/user_stats.dart';
import 'get_activity_history_usecase.dart';

class GetUserStatsUseCase {
  final GetActivityHistoryUseCase _getHistory;

  GetUserStatsUseCase(this._getHistory);

  Future<UserStats> call() async {
    final items = await _getHistory();

    final workouts = items.length;
    final totalDistance = items.fold<double>(0.0, (s, a) => s + a.distanceKm);


    final totalSeconds = items.fold<int>(0, (s, a) => s + a.duration.inSeconds);
    final avgSpeed = totalSeconds == 0
        ? 0.0
        : totalDistance / (totalSeconds / 3600.0); // km / h

    return UserStats(
      workoutsCount: workouts,
      totalDistanceKm: totalDistance,
      avgSpeedKmH: avgSpeed,
    );
  }
}
