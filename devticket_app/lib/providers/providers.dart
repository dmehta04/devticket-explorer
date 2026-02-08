import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/destination.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

// Services
final apiServiceProvider = Provider((ref) => ApiService());
final locationServiceProvider = Provider((ref) => LocationService());

// User location
final userLocationProvider = FutureProvider<UserPosition?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentLocation();
});

// Selected time filter (in minutes)
final timeFilterProvider = StateProvider<int>((ref) => AppConfig.defaultMaxMinutes);

// Selected destination for detail view
final selectedDestinationProvider = StateProvider<Destination?>((ref) => null);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Current tab index for bottom nav
final currentTabProvider = StateProvider<int>((ref) => 0);

// Destinations from API (filtered by time)
final destinationsProvider = FutureProvider<List<Destination>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final locationAsync = ref.watch(userLocationProvider);
  final maxMinutes = ref.watch(timeFilterProvider);

  final location = locationAsync.valueOrNull;
  final lat = location?.latitude ?? AppConfig.defaultLat;
  final lng = location?.longitude ?? AppConfig.defaultLng;

  return apiService.getDestinations(lat, lng, maxMinutes);
});

// All destinations (for browse screen)
final allDestinationsProvider = FutureProvider<List<Destination>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAllDestinations();
});

// Coverage info
final coverageProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCoverage();
});

// Featured trips
final featuredTripsProvider =
    FutureProvider.family<List<Destination>, String>((ref, tripType) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getFeaturedTrips(
      tripType: tripType.isEmpty ? null : tripType);
});

// Search results
final searchResultsProvider = FutureProvider<List<Destination>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final apiService = ref.watch(apiServiceProvider);
  final locationAsync = ref.watch(userLocationProvider);

  final location = locationAsync.valueOrNull;
  final lat = location?.latitude ?? AppConfig.defaultLat;
  final lng = location?.longitude ?? AppConfig.defaultLng;

  return apiService.searchDestinations(query, lat, lng);
});
