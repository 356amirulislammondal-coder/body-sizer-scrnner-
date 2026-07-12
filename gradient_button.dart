import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A full-width, pill-shaped primary call-to-action button with the brand
/// blue gradient. Used for the main action on nearly every screen (Start
/// Scan, Scan Again, Save Report, etc.) to keep the "premium" feel
/// consistent throughout the app.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? colors;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: disabled
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : (colors ?? AppColors.heroGradient),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
