import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/scan_provider.dart';
import 'providers/theme_provider.dart';
import 'services/image_service.dart';
import 'services/local_storage_service.dart';
import 'services/measurement_estimation_service.dart';
import 'services/pose_detection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local-only persistence (Hive). No network client is ever created
  // anywhere in this app — everything below runs fully on-device.
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  final poseDetectionService = PoseDetectionService();
  final imageService = ImageService();
  final estimationService = MeasurementEstimationService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<PoseDetectionService>.value(value: poseDetectionService),
        Provider<ImageService>.value(value: imageService),
        Provider<MeasurementEstimationService>.value(value: estimationService),
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(
            imageService: imageService,
            poseService: poseDetectionService,
            estimationService: estimationService,
            storageService: localStorageService,
          ),
        ),
      ],
      child: const BodySizeScannerApp(),
    ),
  );
}
