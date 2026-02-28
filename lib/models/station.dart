class Station {
  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final String stationType;

  Station({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.stationType,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stationType: json['station_type'] as String,
    );
  }
}
