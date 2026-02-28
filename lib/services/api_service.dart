import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/destination.dart';
import '../models/station.dart';
import '../models/route_detail.dart';
import '../models/transport_line.dart';
import '../models/place.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<List<Station>> getNearbyStations(
      double lat, double lng, double radius) async {
    final response = await _dio.get('/stations/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
    return (response.data as List)
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Destination>> getDestinations(
      double lat, double lng, int maxMinutes) async {
    final response = await _dio.get('/destinations', queryParameters: {
      'lat': lat,
      'lng': lng,
      'max_minutes': maxMinutes,
    });
    return (response.data as List)
        .map((json) => Destination.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Destination>> searchDestinations(
      String query, double lat, double lng) async {
    final response =
        await _dio.get('/destinations/search', queryParameters: {
      'q': query,
      'lat': lat,
      'lng': lng,
    });
    return (response.data as List)
        .map((json) => Destination.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RouteDetail> getRouteDetail(String fromId, String toId) async {
    final response = await _dio.get('/routes/$fromId/$toId');
    return RouteDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Destination>> getAllDestinations() async {
    final response = await _dio.get('/destinations/all');
    return (response.data as List)
        .map((json) => Destination.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getCoverage() async {
    final response = await _dio.get('/coverage');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Destination>> getFeaturedTrips({String? tripType}) async {
    final params = <String, dynamic>{};
    if (tripType != null && tripType.isNotEmpty) {
      params['trip_type'] = tripType;
    }
    final response = await _dio.get('/trips', queryParameters: params);
    return (response.data as List)
        .map((json) => Destination.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── New: Transport Lines (Features 1 & 4) ──

  Future<List<TransportLine>> getTransportLines({
    String? type,
    String? city,
  }) async {
    final params = <String, dynamic>{};
    if (type != null && type.isNotEmpty) params['transport_type'] = type;
    if (city != null && city.isNotEmpty) params['city'] = city;
    final response =
        await _dio.get('/transport/lines', queryParameters: params);
    return (response.data as List)
        .map((json) => TransportLine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransportLine>> getCircularRoutes({String? city}) async {
    final params = <String, dynamic>{};
    if (city != null && city.isNotEmpty) params['city'] = city;
    final response =
        await _dio.get('/transport/circular-routes', queryParameters: params);
    return (response.data as List)
        .map((json) => TransportLine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── New: Attractions (Feature 5) ──

  Future<List<Attraction>> getAttractions(String destinationId) async {
    final response = await _dio.get('/destinations/$destinationId/attractions');
    return (response.data as List)
        .map((json) => Attraction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── New: Places (Feature 7) ──

  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    String? category,
    int radius = 1000,
  }) async {
    final params = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
    if (category != null) params['category'] = category;
    final response =
        await _dio.get('/places/nearby', queryParameters: params);
    return (response.data as List)
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final response = await _dio.get('/places/$placeId/details');
    return PlaceDetails.fromJson(response.data as Map<String, dynamic>);
  }

  String getPlacePhotoUrl(String placeId, String photoRef) {
    return '${AppConfig.apiBaseUrl}/places/$placeId/photos/$photoRef';
  }
}
