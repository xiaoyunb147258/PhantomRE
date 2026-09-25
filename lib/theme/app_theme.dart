import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF12161F);
  static const Color card = Color(0xFF171C28);
  static const Color neon = Color(0xFF00FF9C);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color danger = Color(0xFFFF4757);
  static const Color warn = Color(0xFFFFB020);
  static const Color textMain = Color(0xFFE8EDF5);
  static const Color textDim = Color(0xFF7A8699);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: neon,
      colorScheme: const ColorScheme.dark(
        primary: neon,
        secondary: neonBlue,
        surface: surface,
        error: danger,
      ),
      fontFamily: 'monospace',
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: neon, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        iconTheme: IconThemeData(color: neon),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1F2733), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1F2733)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1F2733)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neon, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textDim),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neon,
          foregroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
