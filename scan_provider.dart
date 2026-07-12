import 'dart:io';
import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../services/image_service.dart';
import '../services/local_storage_service.dart';
import '../services/measurement_estimation_service.dart';
import '../services/pose_detection_service.dart';

enum ScanStage { idle, detectingBody, estimating, done, error }

/// Coordinates the end-to-end scan pipeline and exposes its progress to the
/// UI. This is the single source of truth the Processing and Results
/// screens listen to via [ChangeNotifier].
class ScanProvider extends ChangeNotifier {
  final ImageService _imageService;
  final PoseDetectionService _poseService;
  final MeasurementEstimationService _estimationService;
  final LocalStorageService _storageService;

  ScanProvider({
    required ImageService imageService,
    required PoseDetectionService poseService,
    required MeasurementEstimationService estimationService,
    required LocalStorageService storageService,
  })  : _imageService = imageService,
        _poseService = poseService,
        _estimationService = estimationService,
        _storageService = storageService;

  ScanStage stage = ScanStage.idle;
  String? errorMessage;
  BodyMeasurement? result;
  File? currentPhoto;

  Future<File?> pickFromGallery() async {
    final file = await _imageService.pickFromGallery();
    if (file != null) currentPhoto = file;
    notifyListeners();
    return file;
  }

  Future<File?> captureFromCamera() async {
    final file = await _imageService.captureFromCamera();
    if (file != null) currentPhoto = file;
    notifyListeners();
    return file;
  }

  /// Runs pose detection + measurement estimation on [currentPhoto] and
  /// persists the resulting [BodyMeasurement] to local storage.
  Future<void> runScan({double? userHeightCm}) async {
    if (currentPhoto == null) {
      stage = ScanStage.error;
      errorMessage = 'No photo selected.';
      notifyListeners();
      return;
    }

    try {
      stage = ScanStage.detectingBody;
      notifyListeners();

      final pose = await _poseService.detectBody(currentPhoto!);
      if (!pose.isUsable) {
        throw StateError(
          'Body not fully visible or confidence too low. Please retake the '
          'photo following the on-screen guidelines.',
        );
      }

      stage = ScanStage.estimating;
      notifyListeners();

      final measurement = _estimationService.estimate(
        pose: pose,
        photoPath: currentPhoto!.path,
        userHeightCm: userHeightCm,
      );

      await _storageService.saveMeasurement(measurement);

      result = measurement;
      stage = ScanStage.done;
      notifyListeners();
    } catch (e) {
      stage = ScanStage.error;
      errorMessage = e is StateError ? e.message : e.toString();
      notifyListeners();
    }
  }

  void reset() {
    stage = ScanStage.idle;
    errorMessage = null;
    result = null;
    currentPhoto = null;
    notifyListeners();
  }
}
