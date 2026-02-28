import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../models/route_detail.dart';
import '../providers/providers.dart';
import '../widgets/transport_badge.dart';

final routeDetailProvider =
    FutureProvider.family<RouteDetail?, (String, String)>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.getRouteDetail(params.$1, params.$2);
  } catch (_) {
    return null;
  }
});

class DestinationDetailScreen extends ConsumerWidget {
  final Destination destination;
  final String nearestStationId;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
    required this.nearestStationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync =
        ref.watch(routeDetailProvider((nearestStationId, destination.id)));
    final timeColor = AppTheme.getTimeColor(destination.travelTimeMinutes);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                destination.city,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      timeColor.withOpacity(0.8),
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Icon(Icons.location_city,
                          size: 56, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(height: 8),
                      Text(
                        destination.state,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      if (destination.region.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            destination.region,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info cards
                  if (destination.travelTimeMinutes > 0) ...[
                    Row(
                      children: [
                        _InfoCard(
                          icon: Icons.access_time,
                          label: 'Travel Time',
                          value: destination.formattedTime,
                          color: timeColor,
                        ),
                        const SizedBox(width: 12),
                        _InfoCard(
                          icon: Icons.swap_horiz,
                          label: 'Transfers',
                          value: '${destination.numberOfTransfers}',
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _InfoCard(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value: destination.formattedDistance,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ICE Comparison Card
                  if (destination.iceMinutes != null &&
                      destination.icePriceEuros != null) ...[
                    _IceComparisonCard(destination: destination),
                    const SizedBox(height: 20),
                  ],

                  // Transport types
                  if (destination.transportTypes.isNotEmpty) ...[
                    const Text(
                      'Transport Types',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: destination.transportTypes.map((t) {
                        return Chip(
                          avatar: TransportBadge(type: t, size: 22),
                          label: Text(AppTheme.getTransportLabel(t)),
                          backgroundColor: AppTheme.getTransportColor(t)
                              .withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // About / Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  // Highlights / Attractions
                  if (destination.highlights.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Top Attractions (${destination.highlights.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...destination.highlights.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Route Details
                  if (destination.travelTimeMinutes > 0) ...[
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(Icons.directions, color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Step-by-Step Directions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    routeAsync.when(
                      data: (route) {
                        if (route == null || route.segments.isEmpty) {
                          return _DirectConnectionCard(destination: destination);
                        }
                        return _RouteTimeline(segments: route.segments);
                      },
                      loading: () => const Center(
                          child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )),
                      error: (e, _) => _DirectConnectionCard(destination: destination),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // D-Ticket info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.confirmation_number,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deutschlandticket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'This trip is fully covered by your \u20ac63/month pass. No extra tickets needed!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await launchUrl(
                                  Uri.parse('https://www.deutschlandticket.de'),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (_) {}
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Buy Deutschlandticket'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IceComparisonCard extends StatelessWidget {
  final Destination destination;
  const _IceComparisonCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    final timeSaved = destination.travelTimeMinutes - (destination.iceMinutes ?? 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'D-Ticket vs ICE/IC',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompareColumn(
                  title: 'Deutschlandticket',
                  time: destination.formattedTime,
                  price: '\u20ac0 extra',
                  color: AppTheme.accent,
                  isHighlighted: true,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.orange.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _CompareColumn(
                  title: 'ICE/IC Train',
                  time: _formatMinutes(destination.iceMinutes ?? 0),
                  price: '\u20ac${destination.icePriceEuros?.toStringAsFixed(2) ?? "0.00"}',
                  color: Colors.orange.shade700,
                  isHighlighted: false,
                ),
              ),
            ],
          ),
          if (timeSaved > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'ICE saves ${timeSaved}min but costs \u20ac${destination.icePriceEuros?.toStringAsFixed(2)} extra per trip',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMinutes(int mins) {
    if (mins == 0) return '-';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

class _CompareColumn extends StatelessWidget {
  final String title;
  final String time;
  final String price;
  final Color color;
  final bool isHighlighted;

  const _CompareColumn({
    required this.title,
    required this.time,
    required this.price,
    required this.color,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isHighlighted ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppTheme.accent : color,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectConnectionCard extends StatelessWidget {
  final Destination destination;
  const _DirectConnectionCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.train, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Direct ${destination.transportTypes.join("/")} connection',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${destination.formattedTime} travel time, ${destination.numberOfTransfers} transfer${destination.numberOfTransfers == 1 ? "" : "s"}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  final List<RouteSegment> segments;
  const _RouteTimeline({required this.segments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start point
        _TimelinePoint(
          label: segments.first.fromStation,
          isFirst: true,
          isLast: false,
        ),
        // Segments
        ...segments.asMap().entries.map((entry) {
          final seg = entry.value;
          final isLast = entry.key == segments.length - 1;
          return Column(
            children: [
              _TimelineSegment(segment: seg),
              _TimelinePoint(
                label: seg.toStation,
                isFirst: false,
                isLast: isLast,
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _TimelinePoint extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isLast;

  const _TimelinePoint({
    required this.label,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 4, color: Colors.grey.shade300),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFirst || isLast) ? AppTheme.primary : Colors.white,
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 4, color: Colors.grey.shade300),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: (isFirst || isLast) ? AppTheme.primary : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineSegment extends StatelessWidget {
  final RouteSegment segment;
  const _TimelineSegment({required this.segment});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getTransportColor(segment.transportType);
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Center(
            child: Container(
              width: 3,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                TransportBadge(type: segment.transportType, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.line,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${segment.fromStation} \u2192 ${segment.toStation}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${segment.durationMinutes}min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
