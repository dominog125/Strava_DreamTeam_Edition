import '../../domain/entities/gps_point.dart';

class GpsPointModel {
  final double lat;
  final double lng;

  const GpsPointModel({required this.lat, required this.lng});

  factory GpsPointModel.fromJson(Map<String, dynamic> json) {
    return GpsPointModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  GpsPoint toEntity() => GpsPoint(lat: lat, lng: lng);

  static GpsPointModel fromEntity(GpsPoint p) => GpsPointModel(lat: p.lat, lng: p.lng);
}
