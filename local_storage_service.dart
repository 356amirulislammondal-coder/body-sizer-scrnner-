import 'package:hive_flutter/hive_flutter.dart';
import '../models/body_measurement.dart';

/// All persistence for this app lives here, backed by Hive — a fast,
/// pure-Dart local key-value database. There is intentionally no network
/// client anywhere in this file: scan history never leaves the device,
/// matching the "no login, no cloud" product requirement.
class LocalStorageService {
  static const String _boxName = 'scan_history';

  late Box<BodyMeasurement> _box;

  /// Call once at app startup (see main.dart) before any screen tries to
  /// read/write scan history.
  Future<void> init() async {
    await Hive.initFlutter();

    Hive
      ..registerAdapter(BodyMeasurementAdapter())
      ..registerAdapter(AccuracyLevelAdapter())
      ..registerAdapter(BodyShapeAdapter());

    _box = await Hive.openBox<BodyMeasurement>(_boxName);
  }

  Future<void> saveMeasurement(BodyMeasurement measurement) async {
    await _box.put(measurement.id, measurement);
  }

  List<BodyMeasurement> getAllMeasurements() {
    final list = _box.values.toList();
    list.sort((a, b) => b.scannedAt.compareTo(a.scannedAt)); // newest first
    return list;
  }

  BodyMeasurement? getById(String id) => _box.get(id);

  Future<void> deleteMeasurement(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAllHistory() async {
    await _box.clear();
  }

  BodyMeasurement? get latest {
    final all = getAllMeasurements();
    return all.isEmpty ? null : all.first;
  }
}
