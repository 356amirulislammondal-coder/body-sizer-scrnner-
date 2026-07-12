import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/unit_converter.dart';
import '../models/body_measurement.dart';
import '../providers/scan_provider.dart';
import '../services/pdf_export_service.dart';
import '../widgets/accuracy_badge.dart';
import '../widgets/body_shape_indicator.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/gradient_button.dart';
import '../widgets/measurement_card.dart';
import 'home_screen.dart';
import 'instructions_screen.dart';

/// The main deliverable screen: photo + every requested measurement (cm &
/// inches), accuracy indicator, BMI, body shape, and the three required
/// actions — Scan Again, Save Report (PDF), Share Report.
class ResultsScreen extends StatefulWidget {
  final BodyMeasurement? measurement; // pass explicitly when opened from History
  const ResultsScreen({super.key, this.measurement});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _pdfService = PdfExportService();
  bool _isExporting = false;

  BodyMeasurement _resolveMeasurement(BuildContext context) {
    return widget.measurement ?? context.read<ScanProvider>().result!;
  }

  Future<void> _saveReport(BodyMeasurement m) async {
    setState(() => _isExporting = true);
    try {
      final file = await _pdfService.generateReport(m);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved: ${file.path.split('/').last}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareReport(BodyMeasurement m) async {
    setState(() => _isExporting = true);
    try {
      final file = await _pdfService.generateReport(m);
      await _pdfService.shareReport(file);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _resolveMeasurement(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        automaticallyImplyLeading: widget.measurement != null,
        leading: widget.measurement != null ? const BackButton() : null,
        actions: [
          if (widget.measurement == null)
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Home',
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          children: [
            _PhotoAndSummary(measurement: m),
            const SizedBox(height: 20),

            Text('Body Shape', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            BodyShapeIndicator(shape: m.bodyShape),

            const SizedBox(height: 24),
            Text('Measurements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                MeasurementCard(icon: Icons.straighten_rounded, label: 'Chest', value: UnitConverter.formatCmWithInches(m.chestCm)),
                MeasurementCard(icon: Icons.straighten_rounded, label: 'Waist', value: UnitConverter.formatCmWithInches(m.waistCm)),
                MeasurementCard(icon: Icons.straighten_rounded, label: 'Hip', value: UnitConverter.formatCmWithInches(m.hipCm)),
                MeasurementCard(icon: Icons.expand_rounded, label: 'Shoulder Width', value: UnitConverter.formatCmWithInches(m.shoulderWidthCm)),
                MeasurementCard(icon: Icons.circle_outlined, label: 'Neck', value: UnitConverter.formatCmWithInches(m.neckCm)),
                MeasurementCard(icon: Icons.accessibility_rounded, label: 'Sleeve Length', value: UnitConverter.formatCmWithInches(m.sleeveLengthCm)),
                MeasurementCard(icon: Icons.front_hand_rounded, label: 'Arm Length', value: UnitConverter.formatCmWithInches(m.armLengthCm)),
                MeasurementCard(icon: Icons.airline_seat_legroom_extra_rounded, label: 'Inseam Length', value: UnitConverter.formatCmWithInches(m.inseamCm)),
                MeasurementCard(icon: Icons.height_rounded, label: 'Height', value: UnitConverter.formatCmWithInches(m.heightCm)),
                MeasurementCard(icon: Icons.monitor_weight_outlined, label: 'Est. Weight', value: UnitConverter.formatKgWithLb(m.estimatedWeightKg)),
              ],
            ),

            const SizedBox(height: 20),
            _BmiCard(measurement: m),

            const SizedBox(height: 20),
            const DisclaimerBanner(),

            const SizedBox(height: 24),
            GradientButton(
              label: 'Scan Again',
              icon: Icons.replay_rounded,
              onPressed: () {
                context.read<ScanProvider>().reset();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const InstructionsScreen()),
                  (route) => route.isFirst,
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _saveReport(m),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Save PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _shareReport(m),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoAndSummary extends StatelessWidget {
  final BodyMeasurement measurement;
  const _PhotoAndSummary({required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            File(measurement.photoPath),
            width: 120,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccuracyBadge(level: measurement.accuracy),
              const SizedBox(height: 10),
              Text(
                measurement.wasHeightCalibrated
                    ? 'Calibrated with your height'
                    : 'Estimated (no manual height entered)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scanned ${_formatDate(measurement.scannedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _BmiCard extends StatelessWidget {
  final BodyMeasurement measurement;
  const _BmiCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  measurement.bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Body Mass Index (BMI)', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    measurement.bmiCategory,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
