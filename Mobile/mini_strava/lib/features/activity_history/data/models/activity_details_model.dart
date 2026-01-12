import '../../domain/entities/activity_details.dart';
import 'activity_summary_model.dart';
import 'gps_point_model.dart';

class ActivityDetailsModel {
  final ActivitySummaryModel summary;
  final List<GpsPointModel> gpsTrack;

  const ActivityDetailsModel({
    required this.summary,
    required this.gpsTrack,
  });

  factory ActivityDetailsModel.fromJson(Map<String, dynamic> json) {
    return ActivityDetailsModel(
      summary: ActivitySummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      gpsTrack: (json['gpsTrack'] as List)
          .map((e) => GpsPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary.toJson(),
    'gpsTrack': gpsTrack.map((e) => e.toJson()).toList(),
  };

  ActivityDetails toEntity() => ActivityDetails(
    summary: summary.toEntity(),
    gpsTrack: gpsTrack.map((e) => e.toEntity()).toList(),
  );
}
