import 'package:latlong2/latlong.dart';
import 'station.dart';

class RouteSegment {
  final String fromStation;
  final String toStation;
  final String transportType;
  final String line;
  final int durationMinutes;
  final List<LatLng> waypoints;

  RouteSegment({
    required this.fromStation,
    required this.toStation,
    required this.transportType,
    required this.line,
    required this.durationMinutes,
    this.waypoints = const [],
  });

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    return RouteSegment(
      fromStation: json['from_station'] as String,
      toStation: json['to_station'] as String,
      transportType: json['transport_type'] as String,
      line: json['line'] as String,
      durationMinutes: json['duration_minutes'] as int,
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((w) {
                final pair = w as List<dynamic>;
                return LatLng(
                  (pair[0] as num).toDouble(),
                  (pair[1] as num).toDouble(),
                );
              })
              .toList() ??
          [],
    );
  }
}

class RouteDetail {
  final Station fromStation;
  final Map<String, dynamic> toDestination;
  final List<RouteSegment> segments;
  final int totalDurationMinutes;
  final int totalTransfers;
  final int? iceMinutes;
  final double? icePriceEuros;

  RouteDetail({
    required this.fromStation,
    required this.toDestination,
    required this.segments,
    required this.totalDurationMinutes,
    required this.totalTransfers,
    this.iceMinutes,
    this.icePriceEuros,
  });

  List<LatLng> get allWaypoints {
    final points = <LatLng>[];
    for (final seg in segments) {
      points.addAll(seg.waypoints);
    }
    return points;
  }

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      fromStation:
          Station.fromJson(json['from_station'] as Map<String, dynamic>),
      toDestination: json['to_destination'] as Map<String, dynamic>,
      segments: (json['segments'] as List<dynamic>)
          .map((e) => RouteSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDurationMinutes: json['total_duration_minutes'] as int,
      totalTransfers: json['total_transfers'] as int,
      iceMinutes: json['ice_minutes'] as int?,
      icePriceEuros: (json['ice_price_euros'] as num?)?.toDouble(),
    );
  }
}
