import 'package:flutter/material.dart';
import '../config/theme.dart';

class TransportBadge extends StatelessWidget {
  final String type;
  final double size;

  const TransportBadge({super.key, required this.type, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.getTransportColor(type),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        AppTheme.getTransportLabel(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
