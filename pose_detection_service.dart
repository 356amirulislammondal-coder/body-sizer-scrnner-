import 'dart:io';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/constants/app_constants.dart';

/// Result of running pose detection on a single image: the raw landmark
/// map plus a quick quality readout so the UI/estimation layer can decide
/// whether the photo is usable and how confident to report results as.
class PoseDetectionResult {
  final Map<PoseLandmarkType, PoseLandmark> landmarks;
  final double detectedLandmarkRatio;
  final bool isUsable;

  PoseDetectionResult({
    required this.landmarks,
    required this.detectedLandmarkRatio,
    required this.isUsable,
  });
}

/// Thin wrapper around `google_mlkit_pose_detection`, Google's on-device
/// pose landmark model (the same MediaPipe BlazePose topology referenced
/// in the product spec — ML Kit ships it under the hood for Android/iOS).
///
/// Kept isolated behind this service so the rest of the app (and the
/// measurement math) never touches the ML Kit API directly — if you later
/// swap in a raw MediaPipe Tasks plugin or a custom TFLite pose model, only
/// this file needs to change.
class PoseDetectionService {
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.single, // single still image, not stream
      model: PoseDetectionModel.accurate,
    ),
  );

  /// Runs pose detection on the given image file and returns the first
  /// (most confident) detected person's landmarks.
  ///
  /// Throws a [StateError] if no human body could be detected at all —
  /// callers should catch this and prompt the user to retake the photo.
  Future<PoseDetectionResult> detectBody(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final poses = await _detector.processImage(inputImage);

    if (poses.isEmpty) {
      throw StateError(
        'No human body detected. Please retake the photo following the '
        'on-screen guidelines.',
      );
    }

    // If multiple people are in frame, pick the one with the highest
    // average landmark confidence (assume it's the intended subject,
    // usually the largest / most centered figure).
    final pose = poses.reduce((a, b) {
      final avgA = _averageConfidence(a.landmarks.values);
      final avgB = _averageConfidence(b.landmarks.values);
      return avgA >= avgB ? a : b;
    });

    final total = PoseLandmarkType.values.length;
    final confident = pose.landmarks.values
        .where((l) => l.likelihood >= AppConstants.minLandmarkConfidence)
        .length;
    final ratio = confident / total;

    return PoseDetectionResult(
      landmarks: pose.landmarks,
      detectedLandmarkRatio: ratio,
      isUsable: ratio >= AppConstants.minRequiredLandmarkRatio,
    );
  }

  double _averageConfidence(Iterable<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return 0;
    final sum = landmarks.fold<double>(0, (s, l) => s + l.likelihood);
    return sum / landmarks.length;
  }

  void dispose() => _detector.close();
}
