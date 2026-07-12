import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's light/dark/system theme preference in a small Hive
/// box (`settings`) so the choice survives app restarts — no login needed.
class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get(_key) as String?;
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final box = await Hive.openBox(_boxName);
    await box.put(_key, mode.name);
  }
}
