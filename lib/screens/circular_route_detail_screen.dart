import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';
import '../models/transport_line.dart';

class CircularRouteDetailScreen extends StatelessWidget {
  final TransportLine line;

  const CircularRouteDetailScreen({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final lineColor = line.color != null
        ? Color(int.parse(line.color!.replaceFirst('#', '0xFF')))
        : AppTheme.getTransportColor(line.transportType);

    final points = line.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    // Close the loop for circular routes
    if (points.length > 2 && line.isCircular) {
      points.add(points.first);
    }

    // Compute center
    double avgLat = 0, avgLng = 0;
    for (final p in line.stops) {
      avgLat += p.lat;
      avgLng += p.lng;
    }
    avgLat /= line.stops.length;
    avgLng /= line.stops.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: lineColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${line.lineName} — ${line.city}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [lineColor, lineColor.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Icon(Icons.loop,
                          size: 48, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(height: 8),
                      Text(
                        'Ring Route',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info bar
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.place,
                        label: '${line.stops.length} stops',
                        color: lineColor,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.loop,
                        label: 'Circular',
                        color: lineColor,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.directions_transit,
                        label: AppTheme.getTransportLabel(line.transportType),
                        color: lineColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    line.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(avgLat, avgLng),
                          initialZoom: 11.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.devticket.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: points,
                                color: lineColor,
                                strokeWidth: 4.0,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: line.stops.map((stop) {
                              return Marker(
                                point: LatLng(stop.lat, stop.lng),
                                width: 28,
                                height: 28,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: lineColor, width: 2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: lineColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stop list
                  Text(
                    'All Stops',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: lineColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...line.stops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stop = entry.value;
                    final isFirst = idx == 0;
                    final isLast = idx == line.stops.length - 1;
                    return _StopRow(
                      name: stop.name,
                      index: idx + 1,
                      isFirst: isFirst,
                      isLast: isLast,
                      color: lineColor,
                    );
                  }),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final String name;
  final int index;
  final bool isFirst;
  final bool isLast;
  final Color color;

  const _StopRow({
    required this.name,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 12, color: color.withOpacity(0.3)),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFirst || isLast) ? color : Colors.white,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 12, color: color.withOpacity(0.3)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: (isFirst || isLast)
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: (isFirst || isLast) ? color : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
