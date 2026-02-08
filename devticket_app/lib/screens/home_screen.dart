import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';
import '../widgets/destination_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/map_widget.dart';
import '../widgets/search_bar_widget.dart';
import 'destination_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Destination? _selectedDestination;

  void _selectDestination(Destination dest) {
    setState(() {
      _selectedDestination =
          _selectedDestination?.id == dest.id ? null : dest;
    });
  }

  void _openDetail(Destination dest) {
    // Find nearest station to use for route detail
    final locationAsync = ref.read(userLocationProvider);
    final location = locationAsync.valueOrNull;

    // Default to Frankfurt station if no location
    String nearestStationId = 'frankfurt_hbf';
    if (location != null) {
      // We'll use a simple heuristic to pick the station
      // The API already found the nearest station for us when getting destinations
      nearestStationId = _guessNearestStation(
          location.latitude, location.longitude);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(
          destination: dest,
          nearestStationId: nearestStationId,
        ),
      ),
    );
  }

  String _guessNearestStation(double lat, double lng) {
    // Simple lookup of nearest major station based on coordinates
    final stations = {
      'berlin_hbf': (52.5251, 13.3694),
      'hamburg_hbf': (53.5526, 10.0067),
      'munich_hbf': (48.1402, 11.5581),
      'cologne_hbf': (50.9429, 6.9589),
      'frankfurt_hbf': (50.1070, 8.6632),
      'stuttgart_hbf': (48.7841, 9.1817),
      'hannover_hbf': (52.3767, 9.7413),
      'leipzig_hbf': (51.3455, 12.3821),
      'dresden_hbf': (51.0404, 13.7320),
      'nuremberg_hbf': (49.4457, 11.0831),
    };

    String nearest = 'frankfurt_hbf';
    double minDist = double.infinity;
    for (final entry in stations.entries) {
      final d = _distance(lat, lng, entry.value.$1, entry.value.$2);
      if (d < minDist) {
        minDist = d;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  double _distance(double lat1, double lng1, double lat2, double lng2) {
    return (lat1 - lat2) * (lat1 - lat2) + (lng1 - lng2) * (lng1 - lng2);
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Map layer (full screen)
          MapWidget(
            selectedDestination: _selectedDestination,
            onMarkerTapped: _selectDestination,
          ),

          // Top gradient overlay for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          Positioned(
            top: topPadding + 8,
            left: 16,
            right: 16,
            child: SearchBarWidget(
              onDestinationSelected: (dest) {
                _selectDestination(dest);
              },
            ),
          ),

          // Time filter chips
          Positioned(
            top: topPadding + 68,
            left: 16,
            child: const TimeFilterChips(),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Info header
          Positioned(
            bottom: 178,
            left: 20,
            right: 20,
            child: destinationsAsync.when(
              data: (destinations) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${destinations.length} destinations',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'reachable with Deutschlandticket',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Destination cards carousel
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 160,
            child: destinationsAsync.when(
              data: (destinations) {
                if (destinations.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'No destinations found. Try increasing the time filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    return DestinationCard(
                      destination: dest,
                      isSelected: _selectedDestination?.id == dest.id,
                      onTap: () {
                        _selectDestination(dest);
                        _openDetail(dest);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
              error: (error, _) => Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off,
                          color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Could not load destinations.\nMake sure the API server is running.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Legend
          Positioned(
            bottom: 188,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppTheme.timeGreen, label: '<1h'),
                  SizedBox(width: 6),
                  _LegendDot(color: AppTheme.timeYellow, label: '<2h'),
                  SizedBox(width: 6),
                  _LegendDot(color: AppTheme.timeOrange, label: '<3h'),
                  SizedBox(width: 6),
                  _LegendDot(color: AppTheme.timeRed, label: '3h+'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
      ],
    );
  }
}
