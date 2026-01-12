import 'activity_summary.dart';
import 'gps_point.dart';

class ActivityDetails {
  final ActivitySummary summary;
  final List<GpsPoint> gpsTrack;

  const ActivityDetails({
    required this.summary,
    required this.gpsTrack,
  });
}
