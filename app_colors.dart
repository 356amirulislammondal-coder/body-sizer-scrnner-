import 'package:flutter/material.dart';

/// Blue & White brand palette used to seed the Material 3 [ColorScheme].
/// Kept separate from [AppTheme] so designers can retune brand colors
/// without touching component theming logic.
class AppColors {
  AppColors._();

  // Brand blues
  static const Color primaryBlue = Color(0xFF1259F4); // core brand blue
  static const Color deepBlue = Color(0xFF0A2FAA);
  static const Color skyBlue = Color(0xFF63A4FF);
  static const Color paleBlue = Color(0xFFE8F0FE);

  // Neutrals
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF6F8FC);
  static const Color charcoal = Color(0xFF161B22);
  static const Color slate = Color(0xFF4A5568);

  // Semantic
  static const Color success = Color(0xFF1FAA59);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE0364A);

  // Accuracy badge colors
  static const Color accuracyHigh = Color(0xFF1FAA59);
  static const Color accuracyMedium = Color(0xFFF5A623);
  static const Color accuracyLow = Color(0xFFE0364A);

  // Gradients
  static const List<Color> heroGradient = [primaryBlue, deepBlue];
  static const List<Color> scanGradient = [skyBlue, primaryBlue];
}
