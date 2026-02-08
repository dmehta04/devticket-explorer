import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import 'transport_badge.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeColor = AppTheme.getTimeColor(destination.travelTimeMinutes);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City name + state
              Row(
                children: [
                  Expanded(
                    child: Text(
                      destination.city,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: timeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      destination.formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: timeColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),
              Text(
                destination.state,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Expanded(
                child: Text(
                  destination.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Bottom row: transport types + distance + transfers
              Row(
                children: [
                  // Transport badges
                  ...destination.transportTypes
                      .take(3)
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: TransportBadge(type: t, size: 24),
                          )),
                  const Spacer(),
                  // Transfers
                  if (destination.numberOfTransfers > 0) ...[
                    Icon(Icons.swap_horiz,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${destination.numberOfTransfers}x',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    destination.formattedDistance,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
