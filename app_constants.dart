/// Central place for every "magic number" and piece of static copy used
/// across the app. Keeping them here makes the estimation logic and the UI
/// easy to tune without hunting through screens.
library;

class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------
  // App identity
  // ---------------------------------------------------------------------
  static const String appName = 'Body Size Scanner';
  static const String appTagline = 'AI body measurements in seconds';

  // ---------------------------------------------------------------------
  // Legal / medical disclaimer
  // Shown on: Instructions screen, Results screen (persistent banner),
  // and Settings/About screen. Required by product spec — must never be
  // removed or hidden behind extra taps.
  // ---------------------------------------------------------------------
  static const String disclaimerShort =
      'AI-estimated measurements are for general guidance only — not exact '
      'tailoring or medical data.';

  static const String disclaimerFull =
      'Body Size Scanner uses on-device computer vision (pose detection) to '
      'estimate body measurements from a single photograph. These figures '
      'are statistical approximations based on body proportions and posture. '
      'They are NOT clinically accurate, are NOT a substitute for '
      'professional tailoring measurements, and are NOT medical advice. '
      'Factors such as clothing, camera angle, lighting, and posture can '
      'affect accuracy. Always verify important measurements (medical, '
      'surgical, or custom-tailoring use) with a measuring tape or a '
      'qualified professional.';

  // ---------------------------------------------------------------------
  // Scan instructions (shown before every scan)
  // ---------------------------------------------------------------------
  static const List<String> scanInstructions = [
    'Stand 2–3 meters (6–10 ft) away from the camera',
    'Make sure the room is well and evenly lit',
    'Wear fitted / form-hugging clothing for best accuracy',
    'Keep your entire body visible in the frame, head to feet',
    'Stand straight, facing the camera, arms relaxed slightly away from your body',
  ];

  // ---------------------------------------------------------------------
  // Pose detection / capture quality thresholds
  // ---------------------------------------------------------------------

  /// Minimum ML Kit landmark confidence (0..1) for a landmark to be trusted.
  static const double minLandmarkConfidence = 0.55;

  /// Minimum fraction of the 33 pose landmarks that must be detected with
  /// acceptable confidence for a scan to proceed at all.
  static const double minRequiredLandmarkRatio = 0.75;

  // ---------------------------------------------------------------------
  // Calibration
  // If the user supplies their real height, we use it to derive a precise
  // pixel→centimeter ratio (HIGH accuracy path). If not, we fall back to an
  // assumed capture distance + typical phone focal length to approximate
  // the same ratio (MEDIUM/LOW accuracy path). This mirrors how every
  // single-camera "AI tailor" app on the market handles the fundamental
  // scale ambiguity of a 2D photo.
  // ---------------------------------------------------------------------
  static const double assumedCaptureDistanceMeters = 2.5;
  static const double defaultHeightCm = 170.0;

  // ---------------------------------------------------------------------
  // Anthropometric ratio table (relative to standing height H).
  // Sourced from published anthropometric survey averages (ANSUR II /
  // classic Leonardo proportion studies) and used as fallback / smoothing
  // priors when a direct landmark-to-landmark pixel measurement is noisy
  // or partially occluded.
  // ---------------------------------------------------------------------
  static const double neckToHeightRatio = 0.182;
  static const double shoulderToHeightRatio = 0.259;
  static const double chestToHeightRatio = 0.545;
  static const double waistToHeightRatio = 0.465;
  static const double hipToHeightRatio = 0.535;
  static const double armLengthToHeightRatio = 0.44;
  static const double sleeveLengthToHeightRatio = 0.33;
  static const double inseamToHeightRatio = 0.45;

  // Unit conversion
  static const double cmToInch = 0.393701;
  static const double kgToLb = 2.20462;
}
