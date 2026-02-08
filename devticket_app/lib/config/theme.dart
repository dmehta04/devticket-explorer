import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // German transport colors
  static const Color primary = Color(0xFF1A237E); // Dark blue (DB Bahn)
  static const Color secondary = Color(0xFFE30613); // DB Red
  static const Color accent = Color(0xFF00A651); // Green for nearby
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBg = Colors.white;

  // Travel time colors
  static const Color timeGreen = Color(0xFF4CAF50); // <60 min
  static const Color timeYellow = Color(0xFFFFC107); // <120 min
  static const Color timeOrange = Color(0xFFFF9800); // <180 min
  static const Color timeRed = Color(0xFFF44336); // 180+ min

  // Transport type colors
  static const Color reColor = Color(0xFF1565C0);
  static const Color rbColor = Color(0xFF42A5F5);
  static const Color sBahnColor = Color(0xFF2E7D32);
  static const Color uBahnColor = Color(0xFF1565C0);
  static const Color tramColor = Color(0xFFE53935);
  static const Color busColor = Color(0xFF7B1FA2);

  static Color getTimeColor(int minutes) {
    if (minutes <= 60) return timeGreen;
    if (minutes <= 120) return timeYellow;
    if (minutes <= 180) return timeOrange;
    return timeRed;
  }

  static Color getTransportColor(String type) {
    switch (type.toUpperCase()) {
      case 'RE':
        return reColor;
      case 'RB':
        return rbColor;
      case 'S_BAHN':
        return sBahnColor;
      case 'U_BAHN':
        return uBahnColor;
      case 'TRAM':
        return tramColor;
      case 'BUS':
        return busColor;
      default:
        return reColor;
    }
  }

  static String getTransportLabel(String type) {
    switch (type.toUpperCase()) {
      case 'RE':
        return 'RE';
      case 'RB':
        return 'RB';
      case 'S_BAHN':
        return 'S';
      case 'U_BAHN':
        return 'U';
      case 'TRAM':
        return 'Tram';
      case 'BUS':
        return 'Bus';
      default:
        return type;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: const CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
