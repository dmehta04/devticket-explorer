import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/transport_line.dart';

class RingRouteCard extends StatelessWidget {
  final TransportLine line;
  final VoidCallback onTap;

  const RingRouteCard({super.key, required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = line.color != null
        ? Color(int.parse(line.color!.replaceFirst('#', '0xFF')))
        : AppTheme.getTransportColor(line.transportType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      line.lineName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.loop, color: Colors.white.withOpacity(0.8), size: 20),
                ],
              ),
              const Spacer(),
              // City
              Text(
                line.city,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Stop count
              Text(
                '${line.stops.length} stops',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
