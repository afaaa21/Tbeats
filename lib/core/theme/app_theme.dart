import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF005235);
  static const primaryContainer = Color(0xFF1A6B4A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF9BE9BF);
  static const primaryFixed = Color(0xFFA5F3C9);

  static const background = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEBEFEA);
  static const surfaceContainerHigh = Color(0xFFE6E9E4);
  static const surfaceContainerLow = Color(0xFFF1F5EF);
  static const outlineVariant = Color(0xFFBFC9C0);
  static const outline = Color(0xFF6F7A72);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const onSurface = Color(0xFF181D1A);
  static const onSurfaceVariant = Color(0xFF3F4943);

  static const danger = Color(0xFFEB5757);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF2994A);
  static const statusNeutral = Color(0xFF9CA3AF);

  static const secondary = Color(0xFF006492);
  static const secondaryContainer = Color(0xFF58BCFD);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onPrimary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: Color(0xFF004A6D),
          tertiary: Color(0xFF753134),
          onTertiary: AppColors.onPrimary,
          tertiaryContainer: Color(0xFF92484A),
          onTertiaryContainer: Color(0xFFFFCCCC),
          error: Color(0xFFBA1A1A),
          onError: AppColors.onPrimary,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: Color(0xFFE0E3DE),
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}