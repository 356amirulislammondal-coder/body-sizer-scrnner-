import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../services/local_storage_service.dart';
import '../widgets/disclaimer_banner.dart';

/// Appearance (light/dark/system) and local data management. No account
/// settings exist here by design — there is no account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  children: [
                    _ThemeOption(
                      label: 'System Default',
                      icon: Icons.brightness_auto_rounded,
                      selected: themeProvider.mode == ThemeMode.system,
                      onTap: () => themeProvider.setMode(ThemeMode.system),
                    ),
                    _ThemeOption(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: themeProvider.mode == ThemeMode.light,
                      onTap: () => themeProvider.setMode(ThemeMode.light),
                    ),
                    _ThemeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: themeProvider.mode == ThemeMode.dark,
                      onTap: () => themeProvider.setMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Your Data', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('Clear Scan History'),
                subtitle: const Text('Removes all locally stored scans permanently'),
                onTap: () => _confirmClear(context),
              ),
            ),

            const SizedBox(height: 24),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Version 1.0.0 · No login required · 100% on-device'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This will permanently delete every saved scan on this device. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<LocalStorageService>().clearAllHistory();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared.')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<bool>(
      value: true,
      groupValue: selected ? true : false,
      onChanged: (_) => onTap(),
      secondary: Icon(icon),
      title: Text(label),
    );
  }
}
