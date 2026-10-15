import 'package:flutter/material.dart';

/// Same palette as the web and React Native apps.
abstract final class AppColors {
  static const brand = Color(0xFF155E63);
  static const success = Color(0xFF2F7A4F);
  static const danger = Color(0xFFB4432E);
  static const dangerSoft = Color(0xFFF7E6E2);
  static const muted = Color(0xFF52606D);
  static const background = Color(0xFFF5F7F8);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    primary: AppColors.brand,
    error: AppColors.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
