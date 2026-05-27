import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1B5E37);
  static const Color lightGreen = Color(0xFF2E7D52);
  static const Color accentGreen = Color(0xFF4CAF7D);
  static const Color bgGray = Color(0xFFF5F5F5);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color lightRed = Color(0xFFFFEBEE);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  static ThemeData get theme => ThemeData(
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: bgGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      );
}

Color getMedicationColor(String name) {
  switch (name.toLowerCase()) {
    case 'isoniazid':
      return const Color(0xFF4CAF7D);
    case 'rifampisin':
      return const Color(0xFFFF8C42);
    case 'pirazinamid':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFF9E9E9E);
  }
}
