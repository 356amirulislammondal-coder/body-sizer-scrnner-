import 'package:hive/hive.dart';

part 'body_measurement.g.dart';

/// Confidence in the estimation, derived from calibration method + how many
/// pose landmarks were detected at acceptable confidence.
@HiveType(typeId: 1)
enum AccuracyLevel {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

/// Simple body-shape classification bucket shown to the user.
@HiveType(typeId: 2)
enum BodyShape {
  @HiveField(0)
  slim,
  @HiveField(1)
  athletic,
  @HiveField(2)
  average,
  @HiveField(3)
  heavy,
}

extension AccuracyLevelX on AccuracyLevel {
  String get label => switch (this) {
        AccuracyLevel.high => 'High',
        AccuracyLevel.medium => 'Medium',
        AccuracyLevel.low => 'Low',
      };
}

extension BodyShapeX on BodyShape {
  String get label => switch (this) {
        BodyShape.slim => 'Slim',
        BodyShape.athletic => 'Athletic',
        BodyShape.average => 'Average',
        BodyShape.heavy => 'Heavy',
      };
}

/// Every value is stored in centimeters (and kilograms for weight); the UI
/// layer converts to inches/pounds on demand via [UnitConverter]. This keeps
/// a single source of truth in the database regardless of which unit the
/// user prefers to view.
@HiveType(typeId: 0)
class BodyMeasurement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime scannedAt;

  /// Absolute path to the saved copy of the captured/uploaded photo on
  /// device storage. Never uploaded anywhere.
  @HiveField(2)
  final String photoPath;

  @HiveField(3)
  final double heightCm;

  @HiveField(4)
  final double chestCm;

  @HiveField(5)
  final double waistCm;

  @HiveField(6)
  final double hipCm;

  @HiveField(7)
  final double shoulderWidthCm;

  @HiveField(8)
  final double neckCm;

  @HiveField(9)
  final double sleeveLengthCm;

  @HiveField(10)
  final double armLengthCm;

  @HiveField(11)
  final double inseamCm;

  @HiveField(12)
  final double estimatedWeightKg;

  @HiveField(13)
  final double bmi;

  @HiveField(14)
  final BodyShape bodyShape;

  @HiveField(15)
  final AccuracyLevel accuracy;

  /// True if the user supplied their real height for calibration
  /// (produces a much more accurate scale-reference than the distance
  /// assumption fallback).
  @HiveField(16)
  final bool wasHeightCalibrated;

  BodyMeasurement({
    required this.id,
    required this.scannedAt,
    required this.photoPath,
    required this.heightCm,
    required this.chestCm,
    required this.waistCm,
    required this.hipCm,
    required this.shoulderWidthCm,
    required this.neckCm,
    required this.sleeveLengthCm,
    required this.armLengthCm,
    required this.inseamCm,
    required this.estimatedWeightKg,
    required this.bmi,
    required this.bodyShape,
    required this.accuracy,
    required this.wasHeightCalibrated,
  });

  /// BMI category label (standard WHO adult thresholds).
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
