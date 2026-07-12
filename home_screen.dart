import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/disclaimer_banner.dart';
import 'instructions_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// The very first interactive screen — no login wall, no onboarding forms.
/// A single primary action ("Start Scan") gets the user into the flow
/// immediately, per the "open app and start scanning" requirement.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Scan History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              _HeroIllustration(scheme: scheme),
              const SizedBox(height: 28),
              Text(
                'Scan Your Body,\nGet Instant Measurements',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Snap or upload a full-body photo and let on-device AI '
                'estimate your chest, waist, hip, and 6 more measurements — '
                'instantly, privately, no account needed.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Start Scan',
                icon: Icons.camera_alt_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InstructionsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              const DisclaimerBanner(compact: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  final ColorScheme scheme;
  const _HeroIllustration({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.paleBlue,
            scheme.brightness == Brightness.dark
                ? AppColors.deepBlue.withOpacity(0.3)
                : AppColors.paleBlue,
          ],
        ),
      ),
      child: Icon(
        Icons.accessibility_new_rounded,
        size: 100,
        color: AppColors.primaryBlue,
      ),
    );
  }
}
