import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';

class MapWidget extends ConsumerStatefulWidget {
  final Destination? selectedDestination;
  final void Function(Destination destination) onMarkerTapped;

  const MapWidget({
    super.key,
    this.selectedDestination,
    required this.onMarkerTapped,
  });

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);
    final locationAsync = ref.watch(userLocationProvider);

    final userLat =
        locationAsync.valueOrNull?.latitude ?? AppConfig.defaultLat;
    final userLng =
        locationAsync.valueOrNull?.longitude ?? AppConfig.defaultLng;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(userLat, userLng),
        initialZoom: AppConfig.defaultZoom,
        minZoom: AppConfig.minZoom,
        maxZoom: AppConfig.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Map tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.devticket.app',
          maxZoom: 19,
        ),

        // Route lines from user to destinations
        destinationsAsync.when(
          data: (destinations) {
            final lines = <Polyline>[];
            for (final dest in destinations) {
              final isSelected = widget.selectedDestination?.id == dest.id;
              lines.add(
                Polyline(
                  points: [
                    LatLng(userLat, userLng),
                    LatLng(dest.latitude, dest.longitude),
                  ],
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.8)
                      : AppTheme.getTimeColor(dest.travelTimeMinutes)
                          .withOpacity(0.3),
                  strokeWidth: isSelected ? 3.0 : 1.5,
                  isDotted: !isSelected,
                ),
              );
            }
            return PolylineLayer(polylines: lines);
          },
          loading: () => const PolylineLayer(polylines: []),
          error: (_, __) => const PolylineLayer(polylines: []),
        ),

        // User location marker
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(userLat, userLng),
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Destination markers
        destinationsAsync.when(
          data: (destinations) => MarkerLayer(
            markers: destinations.map((dest) {
              final isSelected = widget.selectedDestination?.id == dest.id;
              final timeColor =
                  AppTheme.getTimeColor(dest.travelTimeMinutes);

              return Marker(
                point: LatLng(dest.latitude, dest.longitude),
                width: isSelected ? 56 : 44,
                height: isSelected ? 64 : 52,
                child: GestureDetector(
                  onTap: () => widget.onMarkerTapped(dest),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          dest.formattedTime,
                          style: TextStyle(
                            fontSize: isSelected ? 10 : 8,
                            fontWeight: FontWeight.bold,
                            color: timeColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: isSelected ? AppTheme.primary : timeColor,
                        size: isSelected ? 32 : 24,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          loading: () => const MarkerLayer(markers: []),
          error: (_, __) => const MarkerLayer(markers: []),
        ),
      ],
    );
  }

  void animateTo(LatLng target, {double? zoom}) {
    _mapController.move(target, zoom ?? _mapController.camera.zoom);
  }
}
