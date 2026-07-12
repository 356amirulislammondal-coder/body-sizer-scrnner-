import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/body_measurement.dart';
import '../services/local_storage_service.dart';
import '../widgets/accuracy_badge.dart';
import 'results_screen.dart';

/// Lists every past scan pulled from the on-device Hive box. There is no
/// network call anywhere in this screen — history is 100% local, matching
/// the "no cloud storage" requirement.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<BodyMeasurement> _items;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final storage = context.read<LocalStorageService>();
    setState(() => _items = storage.getAllMeasurements());
  }

  Future<void> _delete(BodyMeasurement m) async {
    await context.read<LocalStorageService>().deleteMeasurement(m.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: SafeArea(
        child: _items.isEmpty
            ? _EmptyHistory()
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final m = _items[index];
                  return Dismissible(
                    key: ValueKey(m.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) => _delete(m),
                    child: _HistoryTile(
                      measurement: m,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(measurement: m),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No scans yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Your completed scans will appear here — stored only on this device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final BodyMeasurement measurement;
  final VoidCallback onTap;
  const _HistoryTile({required this.measurement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(measurement.photoPath),
                  width: 64,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${measurement.bodyShape.label} · BMI ${measurement.bmi.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(measurement.scannedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    AccuracyBadge(level: measurement.accuracy),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
