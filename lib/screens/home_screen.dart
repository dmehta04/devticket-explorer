import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';
import '../utils/station_utils.dart';
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
  void _toggleDestination(Destination dest) {
    final notifier = ref.read(selectedDestinationIdsProvider.notifier);
    final current = ref.read(selectedDestinationIdsProvider);
    if (current.contains(dest.id)) {
      notifier.state = {...current}..remove(dest.id);
      // Stop animation if unselecting the animated route
      if (ref.read(animatedRouteDestinationProvider) == dest.id) {
        ref.read(animatedRouteDestinationProvider.notifier).state = null;
      }
    } else {
      notifier.state = {...current, dest.id};
    }
  }

  void _startAnimation(Destination dest) {
    // Ensure destination is selected
    final current = ref.read(selectedDestinationIdsProvider);
    if (!current.contains(dest.id)) {
      ref.read(selectedDestinationIdsProvider.notifier).state = {
        ...current,
        dest.id
      };
    }
    ref.read(animatedRouteDestinationProvider.notifier).state = dest.id;
    ref.read(animationPlayingProvider.notifier).state = true;
  }

  void _stopAnimation() {
    ref.read(animatedRouteDestinationProvider.notifier).state = null;
    ref.read(animationPlayingProvider.notifier).state = true;
  }

  void _clearAll() {
    ref.read(selectedDestinationIdsProvider.notifier).state = {};
    ref.read(animatedRouteDestinationProvider.notifier).state = null;
  }

  void _openDetail(Destination dest) {
    final locationAsync = ref.read(userLocationProvider);
    final location = locationAsync.valueOrNull;

    String nearestStationId = 'frankfurt_hbf';
    if (location != null) {
      nearestStationId =
          guessNearestStation(location.latitude, location.longitude);
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

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);
    final selectedIds = ref.watch(selectedDestinationIdsProvider);
    final animatedDestId = ref.watch(animatedRouteDestinationProvider);
    final isAnimPlaying = ref.watch(animationPlayingProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Map layer (full screen)
          MapWidget(
            onMarkerTapped: _toggleDestination,
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
                _toggleDestination(dest);
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
                    return GestureDetector(
                      onLongPress: () => _startAnimation(dest),
                      child: DestinationCard(
                        destination: dest,
                        isSelected: selectedIds.contains(dest.id),
                        onTap: () => _openDetail(dest),
                      ),
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

          // Clear all FAB (when multiple selected)
          if (selectedIds.length > 1)
            Positioned(
              top: topPadding + 108,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'clearAll',
                onPressed: _clearAll,
                backgroundColor: Colors.white,
                child: const Icon(Icons.clear_all, color: AppTheme.primary),
              ),
            ),

          // Animation controls (when animating)
          if (animatedDestId != null)
            Positioned(
              top: topPadding + 108,
              left: 16,
              child: Row(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'animPlayPause',
                    onPressed: () {
                      ref.read(animationPlayingProvider.notifier).state =
                          !isAnimPlaying;
                    },
                    backgroundColor: AppTheme.primary,
                    child: Icon(
                      isAnimPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'animStop',
                    onPressed: _stopAnimation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.stop, color: AppTheme.primary),
                  ),
                ],
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
