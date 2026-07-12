import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/body_measurement.dart';

/// Small colored pill communicating estimation confidence (High/Medium/Low)
/// as required on the results screen — set by [MeasurementEstimationService]
/// based on whether the user calibrated with their real height and how many
/// pose landmarks were confidently detected.
class AccuracyBadge extends StatelessWidget {
  final AccuracyLevel level;
  const AccuracyBadge({super.key, required this.level});

  Color get _color => switch (level) {
        AccuracyLevel.high => AppColors.accuracyHigh,
        AccuracyLevel.medium => AppColors.accuracyMedium,
        AccuracyLevel.low => AppColors.accuracyLow,
      };

  IconData get _icon => switch (level) {
        AccuracyLevel.high => Icons.verified_rounded,
        AccuracyLevel.medium => Icons.info_rounded,
        AccuracyLevel.low => Icons.warning_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 15, color: _color),
          const SizedBox(width: 6),
          Text(
            '${level.label} Accuracy',
            style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
