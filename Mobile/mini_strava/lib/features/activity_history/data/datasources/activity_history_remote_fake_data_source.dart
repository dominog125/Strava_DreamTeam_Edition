import 'activity_history_remote_data_source.dart';
import '../models/activity_details_model.dart';
import '../models/activity_summary_model.dart';
import '../models/gps_point_model.dart';

class ActivityHistoryRemoteFakeDataSource implements ActivityHistoryRemoteDataSource {
  // trzymamy dane w pamięci
  static final List<ActivitySummaryModel> _history = [
    ActivitySummaryModel(
      id: 'a1',
      dateIso: DateTime(2026, 1, 10).toIso8601String(),
      type: 'run',
      durationSeconds: 45 * 60 + 30,
      distanceKm: 8.2,
      paceMinPerKm: 5.5,
      avgSpeedKmH: 10.9,
    ),
    ActivitySummaryModel(
      id: 'a2',
      dateIso: DateTime(2026, 1, 8).toIso8601String(),
      type: 'bike',
      durationSeconds: 1 * 3600 + 20 * 60,
      distanceKm: 32.5,
      paceMinPerKm: 2.5,
      avgSpeedKmH: 24.3,
    ),
    ActivitySummaryModel(
      id: 'a3',
      dateIso: DateTime(2026, 1, 6).toIso8601String(),
      type: 'walk',
      durationSeconds: 30 * 60,
      distanceKm: 2.4,
      paceMinPerKm: 12.5,
      avgSpeedKmH: 4.8,

    ),
  ];

  static final Map<String, List<GpsPointModel>> _tracks = {
    'a1': const [
      GpsPointModel(lat: 52.2297, lng: 21.0122),
      GpsPointModel(lat: 52.2301, lng: 21.0130),
      GpsPointModel(lat: 52.2310, lng: 21.0145),
    ],
    'a2': const [
      GpsPointModel(lat: 52.40, lng: 16.92),
      GpsPointModel(lat: 52.41, lng: 16.93),
      GpsPointModel(lat: 52.42, lng: 16.95),
      GpsPointModel(lat: 52.43, lng: 16.96),
    ],
    'a3': const [
      GpsPointModel(lat: 50.0647, lng: 19.9450),
      GpsPointModel(lat: 50.0650, lng: 19.9460),
    ],
  };

  @override
  Future<List<ActivitySummaryModel>> fetchHistory() async {
    await Future.delayed(const Duration(milliseconds: 120));
    // kopia, żeby UI nie modyfikowało listy
    return List<ActivitySummaryModel>.from(_history);
  }

  @override
  Future<ActivityDetailsModel> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final summary = _history.firstWhere((e) => e.id == id);
    return ActivityDetailsModel(
      summary: summary,
      gpsTrack: _tracks[id] ?? const [],
    );
  }


  Future<void> add(ActivitySummaryModel model) async {
    await Future.delayed(const Duration(milliseconds: 80));
    _history.insert(0, model); // najnowsze na górze
  }
}
