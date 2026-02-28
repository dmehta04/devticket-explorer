import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';
import 'destination_detail_screen.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  String _selectedTripType = '';

  static const List<_TripFilter> _filters = [
    _TripFilter(label: 'All', value: ''),
    _TripFilter(label: 'Day Trips', value: 'day_trip'),
    _TripFilter(label: 'Weekend Getaways', value: 'weekend'),
  ];

  List<Color> _regionGradient(String region) {
    switch (region.toLowerCase()) {
      case 'north':
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'south':
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case 'east':
        return [const Color(0xFFE65100), const Color(0xFFFF9800)];
      case 'west':
        return [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)];
      case 'central':
        return [const Color(0xFF00695C), const Color(0xFF26A69A)];
      default:
        return [AppTheme.primary, AppTheme.primary.withOpacity(0.7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(featuredTripsProvider(_selectedTripType));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Trip Ideas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Trip type filter chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primary.withOpacity(0.1),
                ),
              ),
            ),
            child: Wrap(
              spacing: 10,
              children: _filters.map((filter) {
                final isSelected = _selectedTripType == filter.value;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTripType = filter.value;
                      });
                    }
                  },
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.primary.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ),

          // Trip cards list
          Expanded(
            child: tripsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load trips.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (destinations) {
                if (destinations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.travel_explore,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No trips found for this filter.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    return _TripCard(
                      destination: dest,
                      gradient: _regionGradient(dest.region),
                      onExplore: () => _navigateToDetail(dest),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Destination dest) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DestinationDetailScreen(
        destination: dest,
        nearestStationId: 'frankfurt_hbf',
      ),
    ));
  }
}

// ─── Filter model ───────────────────────────────────────────────────────────

class _TripFilter {
  final String label;
  final String value;

  const _TripFilter({required this.label, required this.value});
}

// ─── Trip card widget ───────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final Destination destination;
  final List<Color> gradient;
  final VoidCallback onExplore;

  const _TripCard({
    required this.destination,
    required this.gradient,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final highlights = destination.highlights.take(3).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top gradient header with city name and region
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Region badge and trip type badge row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          destination.region.isNotEmpty
                              ? destination.region[0].toUpperCase() +
                                  destination.region.substring(1)
                              : 'Germany',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              destination.tripType == 'weekend'
                                  ? Icons.weekend
                                  : Icons.wb_sunny,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination.tripTypeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // City name
                  Text(
                    destination.city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // State
                  Text(
                    destination.state,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Travel info row
                  Row(
                    children: [
                      _IconLabel(
                        icon: Icons.access_time,
                        label: destination.formattedTime,
                      ),
                      const SizedBox(width: 16),
                      _IconLabel(
                        icon: Icons.swap_horiz,
                        label:
                            '${destination.numberOfTransfers} transfer${destination.numberOfTransfers == 1 ? '' : 's'}',
                      ),
                      const SizedBox(width: 16),
                      _IconLabel(
                        icon: Icons.straighten,
                        label: destination.formattedDistance,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom white section with description, highlights, and button
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    destination.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Highlights chips
                  if (highlights.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: highlights.map((highlight) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: gradient[0].withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: gradient[0].withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            highlight,
                            style: TextStyle(
                              fontSize: 12,
                              color: gradient[0],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Explore button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onExplore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradient[0],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small icon + label helper for the gradient header ──────────────────────

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
