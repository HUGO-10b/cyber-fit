import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberpunkTheme {
  // Brand Colors
  static const Color background = Color(0xFF08080A);
  static const Color cardSurface = Color(0xFF111216);
  static const Color cardSurfaceLight = Color(0xFF1A1C23);

  // Neon Green Accents
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color neonGreenAccent = Color(0xFF39FF14);
  static const Color neonGreenMuted = Color(0xFF14532D);
  static const Color neonGlow = Color(0x6600FF66);

  // Accent Alert & Status
  static const Color neonRed = Color(0xFFFF0055);
  static const Color neonYellow = Color(0xFFFFE600);
  static const Color neonCyan = Color(0xFF00F0FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA7);
  static const Color textMuted = Color(0xFF5E5E6B);

  // Box Shadows for Neon Glow
  static List<BoxShadow> neonGlowShadow({Color color = neonGreen, double spread = 1.0, double blur = 12.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.35),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonCyan,
        surface: cardSurface,
        background: background,
        error: neonRed,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: neonGreen),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardSurface,
        selectedItemColor: neonGreen,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: neonGreen.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }
}
