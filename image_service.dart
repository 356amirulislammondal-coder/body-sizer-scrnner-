import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Wraps [ImagePicker] and handles copying the chosen/captured photo into
/// the app's private document directory so it survives independently of
/// wherever the OS temp cache or gallery entry it came from.
class ImageService {
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<File?> captureFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    if (xFile == null) return null;
    return _persistLocally(File(xFile.path));
  }

  Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return null;
    return _persistLocally(File(xFile.path));
  }

  /// Copies the picked image into `<appDocuments>/scans/<uuid>.jpg` so it
  /// has a stable, app-owned path we can safely store in Hive and reopen
  /// later from the history screen — even if the original gallery/camera
  /// temp file gets cleared by the OS.
  Future<File> _persistLocally(File source) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${docsDir.path}/scans');
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }
    final destPath = '${scansDir.path}/${_uuid.v4()}.jpg';
    return source.copy(destPath);
  }
}
