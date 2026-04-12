import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Mode'),
            subtitle: Text(_themeModeName(themeProvider.themeMode)),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                themeProvider.setThemeMode(newSelection.first);
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account (Coming Soon)'),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Supabase Account'),
            subtitle: const Text('Sign in to sync your CVs'),
            enabled: false,
            onTap: () {
              // TODO: Implement Supabase Auth
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('SmartCV Builder'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System (follows device)';
    }
  }
}
