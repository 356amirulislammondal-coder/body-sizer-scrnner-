import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

/// Root widget. Reads the current [ThemeMode] from [ThemeProvider] so the
/// Light/Dark/System toggle in Settings takes effect instantly app-wide.
class BodySizeScannerApp extends StatelessWidget {
  const BodySizeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
