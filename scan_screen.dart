import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';
import 'processing_screen.dart';

/// Lets the user capture a new photo or pick one from the gallery, then
/// optionally enter their real height for a much more accurate scale
/// calibration before kicking off pose detection.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedPhoto;
  final _heightController = TextEditingController();
  bool _useCm = true;

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pick(bool fromCamera) async {
    final scanProvider = context.read<ScanProvider>();
    final file = fromCamera
        ? await scanProvider.captureFromCamera()
        : await scanProvider.pickFromGallery();
    if (file != null) setState(() => _selectedPhoto = file);
  }

  double? get _parsedHeightCm {
    final raw = double.tryParse(_heightController.text.trim());
    if (raw == null) return null;
    return _useCm ? raw : raw * 2.54; // inches -> cm
  }

  void _startScan() {
    final scanProvider = context.read<ScanProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(userHeightCm: _parsedHeightCm),
      ),
    );
    scanProvider.runScan(userHeightCm: _parsedHeightCm);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Capture Photo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: _selectedPhoto == null
                    ? _EmptyPhotoState(
                        onCamera: () => _pick(true),
                        onGallery: () => _pick(false),
                      )
                    : _PhotoPreview(
                        file: _selectedPhoto!,
                        onRetake: () => setState(() => _selectedPhoto = null),
                      ),
              ),
              if (_selectedPhoto != null) ...[
                const SizedBox(height: 16),
                _HeightCalibrationCard(
                  controller: _heightController,
                  useCm: _useCm,
                  onUnitChanged: (v) => setState(() => _useCm = v),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Analyze Body',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _startScan,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPhotoState extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const _EmptyPhotoState({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outlineVariant,
              width: 1.4,
              style: BorderStyle.solid,
            ),
            color: scheme.surfaceContainerLow,
          ),
          child: Column(
            children: [
              Icon(Icons.person_pin_circle_outlined, size: 72, color: AppColors.primaryBlue.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text('No photo selected', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Take a full-body photo or choose one from your gallery',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final File file;
  final VoidCallback onRetake;
  const _PhotoPreview({required this.file, required this.onRetake});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(file, fit: BoxFit.cover, width: double.infinity),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetake,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Choose a different photo'),
        ),
      ],
    );
  }
}

class _HeightCalibrationCard extends StatelessWidget {
  final TextEditingController controller;
  final bool useCm;
  final ValueChanged<bool> onUnitChanged;

  const _HeightCalibrationCard({
    required this.controller,
    required this.useCm,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.height_rounded, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Your height (optional, improves accuracy)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: useCm ? 'e.g. 170' : 'e.g. 67',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('cm')),
                    ButtonSegment(value: false, label: Text('in')),
                  ],
                  selected: {useCm},
                  onSelectionChanged: (s) => onUnitChanged(s.first),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
