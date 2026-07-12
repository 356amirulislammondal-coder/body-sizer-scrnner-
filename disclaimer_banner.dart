import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Persistent, unmissable notice that measurements are AI estimates only.
/// Required by the product spec to appear before scanning and on results —
/// deliberately NOT hidden behind a dialog the user has to dismiss once and
/// never see again, since it needs to stay visible every time.
class DisclaimerBanner extends StatelessWidget {
  final bool compact;
  const DisclaimerBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              compact ? AppConstants.disclaimerShort : AppConstants.disclaimerFull,
              style: TextStyle(
                fontSize: compact ? 12 : 12.5,
                height: 1.4,
                color: scheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
