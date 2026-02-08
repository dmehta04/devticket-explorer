class Destination {
  final String id;
  final String name;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String description;
  final String region;
  final List<String> highlights;
  final String tripType;
  final int travelTimeMinutes;
  final int numberOfTransfers;
  final List<String> transportTypes;
  final double distanceKm;
  final int? iceMinutes;
  final double? icePriceEuros;

  Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.region = '',
    this.highlights = const [],
    this.tripType = 'day_trip',
    this.travelTimeMinutes = 0,
    this.numberOfTransfers = 0,
    this.transportTypes = const [],
    this.distanceKm = 0.0,
    this.iceMinutes,
    this.icePriceEuros,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      region: json['region'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tripType: json['trip_type'] as String? ?? 'day_trip',
      travelTimeMinutes: json['travel_time_minutes'] as int? ?? 0,
      numberOfTransfers: json['number_of_transfers'] as int? ?? 0,
      transportTypes: (json['transport_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      iceMinutes: json['ice_minutes'] as int?,
      icePriceEuros: (json['ice_price_euros'] as num?)?.toDouble(),
    );
  }

  String get formattedTime {
    if (travelTimeMinutes == 0) return '-';
    final hours = travelTimeMinutes ~/ 60;
    final mins = travelTimeMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  String get formattedDistance {
    return '${distanceKm.round()} km';
  }

  String get tripTypeLabel {
    switch (tripType) {
      case 'weekend':
        return 'Weekend Getaway';
      case 'day_trip':
        return 'Day Trip';
      default:
        return 'Day Trip';
    }
  }
}
