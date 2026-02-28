import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/destination.dart';
import '../models/place.dart';
import '../models/route_detail.dart';
import '../models/transport_line.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/station_utils.dart';

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

// ═══════════════════════════════════════════════════════════════
// NEW PROVIDERS — Features 1-7
// ═══════════════════════════════════════════════════════════════

// ── Feature 1: Transport Lines ──

final transportLinesProvider = FutureProvider.family<List<TransportLine>,
    ({String type, String? city})>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getTransportLines(type: params.type, city: params.city);
});

// ── Feature 2: Multi-select destinations on map ──

final selectedDestinationIdsProvider = StateProvider<Set<String>>((ref) => {});

final selectedRoutesProvider =
    FutureProvider<Map<String, RouteDetail?>>((ref) async {
  final selectedIds = ref.watch(selectedDestinationIdsProvider);
  if (selectedIds.isEmpty) return {};

  final apiService = ref.watch(apiServiceProvider);
  final locationAsync = ref.watch(userLocationProvider);

  final location = locationAsync.valueOrNull;
  final lat = location?.latitude ?? AppConfig.defaultLat;
  final lng = location?.longitude ?? AppConfig.defaultLng;
  final nearestStationId = guessNearestStation(lat, lng);

  final results = <String, RouteDetail?>{};
  await Future.wait(selectedIds.map((destId) async {
    try {
      results[destId] =
          await apiService.getRouteDetail(nearestStationId, destId);
    } catch (_) {
      results[destId] = null;
    }
  }));
  return results;
});

// ── Feature 3: Animated vehicle ──

final animatedRouteDestinationProvider =
    StateProvider<String?>((ref) => null);
final animationPlayingProvider = StateProvider<bool>((ref) => true);

// ── Feature 4: Circular routes ──

final circularRoutesProvider =
    FutureProvider<List<TransportLine>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCircularRoutes();
});

// ── Feature 5: Attractions ──

final attractionsProvider =
    FutureProvider.family<List<Attraction>, String>((ref, destinationId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAttractions(destinationId);
});

// ── Feature 6: Map focus ──

final mapFocusDestinationProvider =
    StateProvider<Destination?>((ref) => null);

// ── Feature 7: Places ──

final placesProvider = FutureProvider.family<List<Place>,
    ({String destinationId, String? category})>((ref, params) async {
  // Get destination coordinates for the Places API
  final allDests = ref.watch(allDestinationsProvider);
  final dests = allDests.valueOrNull ?? [];
  final dest = dests.where((d) => d.id == params.destinationId).firstOrNull;

  if (dest == null) return [];

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getNearbyPlaces(
    lat: dest.latitude,
    lng: dest.longitude,
    category: params.category,
  );
});

final placeCategoryProvider = StateProvider<String?>((ref) => null);

final placeDetailsProvider =
    FutureProvider.family<PlaceDetails, String>((ref, placeId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPlaceDetails(placeId);
});
