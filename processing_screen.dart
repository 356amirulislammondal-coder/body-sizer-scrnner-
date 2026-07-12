import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';
import 'results_screen.dart';

/// Displays live pipeline progress (detecting body → estimating
/// measurements) while [ScanProvider.runScan] executes, then automatically
/// navigates to [ResultsScreen] on success, or shows a retry option on
/// failure (e.g. body not detected / low confidence).
class ProcessingScreen extends StatefulWidget {
  final double? userHeightCm;
  const ProcessingScreen({super.key, this.userHeightCm});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ScanProvider>(
          builder: (context, scan, _) {
            if (scan.stage == ScanStage.done && scan.result != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ResultsScreen()),
                );
              });
            }

            if (scan.stage == ScanStage.error) {
              return _ErrorState(
                message: scan.errorMessage ?? 'Something went wrong.',
                onRetry: () => Navigator.of(context).pop(),
              );
            }

            return _ProgressState(stage: scan.stage);
          },
        ),
      ),
    );
  }
}

class _ProgressState extends StatelessWidget {
  final ScanStage stage;
  const _ProgressState({required this.stage});

  String get _label => switch (stage) {
        ScanStage.detectingBody => 'Detecting body landmarks…',
        ScanStage.estimating => 'Calculating measurements…',
        _ => 'Preparing…',
      };

  double get _progress => switch (stage) {
        ScanStage.detectingBody => 0.45,
        ScanStage.estimating => 0.85,
        _ => 0.1,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: AppColors.paleBlue,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                  ),
                  const Icon(Icons.accessibility_new_rounded, size: 44, color: AppColors.primaryBlue),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(_label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Running on-device AI — your photo never leaves your phone.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Scan Failed', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
