import '../constants/app_constants.dart';

/// Simple, dependency-free unit conversions used throughout the results
/// screen and PDF export so every measurement can be displayed in both
/// centimeters/inches and kilograms/pounds.
class UnitConverter {
  UnitConverter._();

  static double cmToInches(double cm) => cm * AppConstants.cmToInch;

  static double kgToLb(double kg) => kg * AppConstants.kgToLb;

  /// Formats a centimeter value as "XX.X cm (YY.Y in)".
  static String formatCmWithInches(double cm, {int decimals = 1}) {
    final inches = cmToInches(cm);
    return '${cm.toStringAsFixed(decimals)} cm (${inches.toStringAsFixed(decimals)} in)';
  }

  /// Formats a kilogram value as "XX.X kg (YY.Y lb)".
  static String formatKgWithLb(double kg, {int decimals = 1}) {
    final lb = kgToLb(kg);
    return '${kg.toStringAsFixed(decimals)} kg (${lb.toStringAsFixed(decimals)} lb)';
  }
}
