import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/body_measurement.dart';

/// Highlights the estimated [BodyShape] bucket among the four possible
/// categories, with the active one visually emphasized.
class BodyShapeIndicator extends StatelessWidget {
  final BodyShape shape;
  const BodyShapeIndicator({super.key, required this.shape});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: BodyShape.values.map((s) {
        final isActive = s == shape;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBlue : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              s.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
