import 'package:latlong2/latlong.dart';

class TransportLineStop {
  final String name;
  final double lat;
  final double lng;

  TransportLineStop({
    required this.name,
    required this.lat,
    required this.lng,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory TransportLineStop.fromJson(Map<String, dynamic> json) {
    return TransportLineStop(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class TransportLine {
  final String id;
  final String transportType;
  final String lineName;
  final String city;
  final String description;
  final bool isCircular;
  final String? color;
  final List<TransportLineStop> stops;

  TransportLine({
    required this.id,
    required this.transportType,
    required this.lineName,
    required this.city,
    required this.description,
    this.isCircular = false,
    this.color,
    this.stops = const [],
  });

  List<LatLng> get waypoints => stops.map((s) => s.latLng).toList();

  factory TransportLine.fromJson(Map<String, dynamic> json) {
    return TransportLine(
      id: json['id'] as String,
      transportType: json['transport_type'] as String,
      lineName: json['line_name'] as String,
      city: json['city'] as String,
      description: json['description'] as String,
      isCircular: json['is_circular'] as bool? ?? false,
      color: json['color'] as String?,
      stops: (json['stops'] as List<dynamic>?)
              ?.map(
                  (e) => TransportLineStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
