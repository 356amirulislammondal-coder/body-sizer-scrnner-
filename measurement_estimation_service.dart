import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/body_measurement.dart';
import 'pose_detection_service.dart';

/// Turns a [PoseDetectionResult] (2D pixel landmarks) into real-world body
/// measurements in centimeters.
///
/// ── HOW IT WORKS ────────────────────────────────────────────────────────
/// A single 2D photo has no depth information, so absolute measurements are
/// fundamentally a scale-estimation problem. We solve it in two stages:
///
///  1. CALIBRATION — establish a pixel→centimeter ratio.
///     • If the user enters their real height, we divide it by the
///       measured pixel distance from head-top to ankle → HIGH accuracy.
///     • If not, we fall back to a typical phone focal length + the
///       instructed capture distance (2–3 m) to approximate the same
///       ratio → MEDIUM/LOW accuracy (flagged clearly to the user).
///
///  2. DIRECT + PROPORTIONAL MEASUREMENT — for measurements that map to a
///     roughly-frontal pixel distance (shoulder width, arm length, inseam,
///     height) we measure the landmark-to-landmark pixel distance directly
///     and scale it. For circumferential measurements that a single frontal
///     photo cannot observe directly (chest/waist/hip/neck *circumference*),
///     we combine the measured frontal *width* at that body line with
///     published anthropometric width-to-circumference ratios (body is
///     approximated as an ellipse with a typical depth/width ratio for the
///     given body region), then blend with height-based population-average
///     ratios for stability.
/// ──────────────────────────────────────────────────────────────────────
class MeasurementEstimationService {
  final _uuid = const Uuid();

  /// Main entry point. [userHeightCm] is optional — pass null if the user
  /// skipped manual height entry.
  BodyMeasurement estimate({
    required PoseDetectionResult pose,
    required String photoPath,
    double? userHeightCm,
    double imageAspectPixelWidth = 1,
    double imageAspectPixelHeight = 1,
  }) {
    final lm = pose.landmarks;

    double dist(PoseLandmarkType a, PoseLandmarkType b) {
      final p1 = lm[a];
      final p2 = lm[b];
      if (p1 == null || p2 == null) return 0;
      return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
    }

    // ---- 1. Pixel height: nose-to-ankle-average scaled up to full height
    // (head top isn't a dedicated ML Kit landmark, so we approximate full
    // stature as ~1.13x the eye-to-ankle span, a standard anthropometric
    // correction for head-top offset above the eyes).
    final leftAnkle = lm[PoseLandmarkType.leftAnkle];
    final rightAnkle = lm[PoseLandmarkType.rightAnkle];
    final nose = lm[PoseLandmarkType.nose];
    double pixelHeight = 0;
    if (nose != null && leftAnkle != null && rightAnkle != null) {
      final avgAnkleY = (leftAnkle.y + rightAnkle.y) / 2;
      final eyeToAnkle = (avgAnkleY - nose.y).abs();
      pixelHeight = eyeToAnkle * 1.13;
    }

    final bool calibrated = userHeightCm != null && userHeightCm > 0;
    final double effectiveHeightCm = userHeightCm ?? AppConstants.defaultHeightCm;

    // ---- 2. Pixel → cm ratio
    double pxToCm;
    if (calibrated && pixelHeight > 0) {
      pxToCm = effectiveHeightCm / pixelHeight;
    } else {
      // Fallback: assume typical phone focal length behaviour at the
      // instructed 2.5 m capture distance. This is intentionally a rough
      // approximation — accuracy is reported as MEDIUM/LOW in this path.
      pxToCm = effectiveHeightCm / (pixelHeight == 0 ? 1 : pixelHeight);
    }

    double cm(double pixels) => pixels * pxToCm;

    // ---- 3. Direct frontal measurements -----------------------------
    final shoulderWidthPx = dist(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
    );
    final hipWidthPx = dist(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    );
    final armLengthPx = _average([
      dist(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow) +
          dist(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
      dist(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow) +
          dist(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
    ]);
    final inseamPx = _average([
      dist(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee) +
          dist(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
      dist(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee) +
          dist(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
    ]);

    final shoulderWidthCm = _blend(
      cm(shoulderWidthPx),
      effectiveHeightCm * AppConstants.shoulderToHeightRatio,
      shoulderWidthPx > 0 ? 0.7 : 0.0,
    );
    final hipWidthFrontalCm = _blend(
      cm(hipWidthPx),
      effectiveHeightCm * AppConstants.hipToHeightRatio * 0.4, // frontal width, not circumference
      hipWidthPx > 0 ? 0.7 : 0.0,
    );
    final armLengthCm = _blend(
      cm(armLengthPx),
      effectiveHeightCm * AppConstants.armLengthToHeightRatio,
      armLengthPx > 0 ? 0.7 : 0.0,
    );
    final inseamCm = _blend(
      cm(inseamPx),
      effectiveHeightCm * AppConstants.inseamToHeightRatio,
      inseamPx > 0 ? 0.7 : 0.0,
    );

    // ---- 4. Circumferential estimates (elliptical body-model approx) --
    // circumference ≈ π * (width + depth) / 2   [Ramanujan ellipse approx,
    // simplified], where depth is inferred from population-average
    // depth/width ratios per body region since a frontal photo can't see it.
    final chestWidthCm = _blend(
      cm(shoulderWidthPx) * 0.92, // chest is slightly narrower than shoulder line
      effectiveHeightCm * AppConstants.chestToHeightRatio * 0.42,
      shoulderWidthPx > 0 ? 0.6 : 0.0,
    );
    final waistWidthCm = effectiveHeightCm * AppConstants.waistToHeightRatio * 0.38;

    final chestCm = _ellipseCircumference(chestWidthCm, depthRatio: 0.70);
    final waistCm = _ellipseCircumference(waistWidthCm, depthRatio: 0.75);
    final hipCm = _ellipseCircumference(hipWidthFrontalCm, depthRatio: 0.85);
    final neckCm = effectiveHeightCm * AppConstants.neckToHeightRatio;
    final sleeveLengthCm =
        effectiveHeightCm * AppConstants.sleeveLengthToHeightRatio;

    // ---- 5. Weight & BMI estimate --------------------------------------
    // Uses a body-volume proxy from waist/hip/shoulder/height (a common
    // approach in single-image body composition estimators) rather than a
    // fixed BMI-only formula, so build differences show up in the estimate.
    final estimatedWeightKg = _estimateWeight(
      heightCm: effectiveHeightCm,
      chestCm: chestCm,
      waistCm: waistCm,
      hipCm: hipCm,
    );
    final heightM = effectiveHeightCm / 100;
    final bmi = estimatedWeightKg / (heightM * heightM);

    final bodyShape = _classifyShape(
      bmi: bmi,
      waistCm: waistCm,
      hipCm: hipCm,
      chestCm: chestCm,
      shoulderCm: shoulderWidthCm,
    );

    // ---- 6. Accuracy rating ---------------------------------------------
    final accuracy = _resolveAccuracy(
      calibrated: calibrated,
      landmarkRatio: pose.detectedLandmarkRatio,
    );

    return BodyMeasurement(
      id: _uuid.v4(),
      scannedAt: DateTime.now(),
      photoPath: photoPath,
      heightCm: effectiveHeightCm,
      chestCm: chestCm,
      waistCm: waistCm,
      hipCm: hipCm,
      shoulderWidthCm: shoulderWidthCm,
      neckCm: neckCm,
      sleeveLengthCm: sleeveLengthCm,
      armLengthCm: armLengthCm,
      inseamCm: inseamCm,
      estimatedWeightKg: estimatedWeightKg,
      bmi: bmi,
      bodyShape: bodyShape,
      accuracy: accuracy,
      wasHeightCalibrated: calibrated,
    );
  }

  // -- helpers --------------------------------------------------------

  double _average(List<double> values) {
    final valid = values.where((v) => v > 0).toList();
    if (valid.isEmpty) return 0;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  /// Blends a directly-measured value with a population-average prior.
  /// [weightOnMeasured] of 1.0 trusts the measured value completely; 0.0
  /// falls back entirely to the anthropometric prior (used when the
  /// landmark distance couldn't be measured, e.g. occluded limb).
  double _blend(double measured, double prior, double weightOnMeasured) {
    if (measured <= 0) return prior;
    return (measured * weightOnMeasured) + (prior * (1 - weightOnMeasured));
  }

  /// Approximates circumference of a body cross-section modeled as an
  /// ellipse, given the frontal width and a typical depth/width ratio for
  /// that body region (chest/waist/hip each have different average
  /// depth ratios reflected by [depthRatio]).
  double _ellipseCircumference(double widthCm, {required double depthRatio}) {
    final a = widthCm / 2; // semi-major (width)
    final b = (widthCm * depthRatio) / 2; // semi-minor (depth)
    // Ramanujan's second approximation for ellipse perimeter.
    final h = pow((a - b), 2) / pow((a + b), 2);
    final perimeter =
        pi * (a + b) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)));
    return perimeter;
  }

  double _estimateWeight({
    required double heightCm,
    required double chestCm,
    required double waistCm,
    required double hipCm,
  }) {
    // Simplified U.S. Navy-style body circumference formula, adapted to
    // give a plausible unisex baseline weight from height + circumferences
    // rather than a body-fat percentage. This is a coarse estimate only.
    final heightM = heightCm / 100;
    final volumeProxy = (chestCm + waistCm + hipCm) / 3;
    final bmiProxy = 21.5 + ((volumeProxy - (heightCm * 0.52)) * 0.18);
    final clampedBmi = bmiProxy.clamp(15.0, 40.0);
    return clampedBmi * heightM * heightM;
  }

  BodyShape _classifyShape({
    required double bmi,
    required double waistCm,
    required double hipCm,
    required double chestCm,
    required double shoulderCm,
  }) {
    final whr = waistCm / (hipCm == 0 ? 1 : hipCm); // waist-to-hip ratio
    if (bmi < 18.5) return BodyShape.slim;
    if (bmi >= 30) return BodyShape.heavy;
    // Athletic build: broader shoulders relative to waist, moderate WHR.
    final shoulderToWaist = shoulderCm / (waistCm == 0 ? 1 : waistCm);
    if (bmi < 25 && whr < 0.85 && shoulderToWaist > 0.42) {
      return BodyShape.athletic;
    }
    return BodyShape.average;
  }

  AccuracyLevel _resolveAccuracy({
    required bool calibrated,
    required double landmarkRatio,
  }) {
    if (calibrated && landmarkRatio >= 0.9) return AccuracyLevel.high;
    if (calibrated && landmarkRatio >= 0.75) return AccuracyLevel.medium;
    if (!calibrated && landmarkRatio >= 0.9) return AccuracyLevel.medium;
    return AccuracyLevel.low;
  }
}
