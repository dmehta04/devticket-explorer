import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';

class AnimatedVehicleLayer extends StatefulWidget {
  final List<LatLng> routePoints;
  final String transportType;
  final bool isPlaying;

  const AnimatedVehicleLayer({
    super.key,
    required this.routePoints,
    required this.transportType,
    this.isPlaying = true,
  });

  @override
  State<AnimatedVehicleLayer> createState() => _AnimatedVehicleLayerState();
}

class _AnimatedVehicleLayerState extends State<AnimatedVehicleLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedVehicleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LatLng _interpolatePosition(double t) {
    if (widget.routePoints.length < 2) {
      return widget.routePoints.isNotEmpty
          ? widget.routePoints.first
          : const LatLng(50.0, 10.0);
    }

    // Calculate total distance
    double totalDist = 0;
    final distances = <double>[];
    for (int i = 0; i < widget.routePoints.length - 1; i++) {
      final d = _dist(widget.routePoints[i], widget.routePoints[i + 1]);
      distances.add(d);
      totalDist += d;
    }

    if (totalDist == 0) return widget.routePoints.first;

    double targetDist = t * totalDist;
    double cumDist = 0;
    for (int i = 0; i < distances.length; i++) {
      if (cumDist + distances[i] >= targetDist) {
        final segFraction =
            distances[i] > 0 ? (targetDist - cumDist) / distances[i] : 0.0;
        final p1 = widget.routePoints[i];
        final p2 = widget.routePoints[i + 1];
        return LatLng(
          p1.latitude + (p2.latitude - p1.latitude) * segFraction,
          p1.longitude + (p2.longitude - p1.longitude) * segFraction,
        );
      }
      cumDist += distances[i];
    }
    return widget.routePoints.last;
  }

  double _dist(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = (a.longitude - b.longitude) * cos(a.latitude * pi / 180);
    return sqrt(dx * dx + dy * dy);
  }

  IconData _getVehicleIcon() {
    switch (widget.transportType) {
      case 'RE':
      case 'RB':
        return Icons.train;
      case 'S_BAHN':
        return Icons.directions_transit;
      case 'U_BAHN':
        return Icons.subway;
      case 'TRAM':
        return Icons.tram;
      case 'BUS':
        return Icons.directions_bus;
      default:
        return Icons.train;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routePoints.length < 2) return const SizedBox.shrink();

    final color = AppTheme.getTransportColor(widget.transportType);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pos = _interpolatePosition(_controller.value);
        return MarkerLayer(
          markers: [
            Marker(
              point: pos,
              width: 36,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getVehicleIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
