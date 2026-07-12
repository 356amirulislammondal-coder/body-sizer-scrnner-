import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/gradient_button.dart';
import 'scan_screen.dart';

/// Shown before every single scan (not just the first time) so the user is
/// always reminded how to get an accurate result, per the product spec.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  static const _icons = [
    Icons.social_distance_rounded,
    Icons.wb_sunny_outlined,
    Icons.checkroom_rounded,
    Icons.accessibility_new_rounded,
    Icons.straighten_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Before You Scan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: AppConstants.scanInstructions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _InstructionTile(
                      icon: _icons[index % _icons.length],
                      text: AppConstants.scanInstructions[index],
                      index: index + 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const DisclaimerBanner(),
              const SizedBox(height: 16),
              GradientButton(
                label: "I'm Ready — Continue",
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final int index;

  const _InstructionTile({
    required this.icon,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
