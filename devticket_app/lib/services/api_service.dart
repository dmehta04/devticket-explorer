import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/destination.dart';
import '../models/station.dart';
import '../models/route_detail.dart';

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
}
