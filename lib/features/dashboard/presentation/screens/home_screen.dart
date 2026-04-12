import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/screens/editor_screen.dart';
import 'package:smartcv_builder/features/settings/presentation/screens/settings_screen.dart';
import 'package:smartcv_builder/features/settings/presentation/providers/theme_provider.dart';
import 'package:smartcv_builder/core/utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCV Builder'),
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon(context)),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: Responsive.constrained(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Create Your Professional CV',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A streamlined editor with live preview to help you build your perfect resume in minutes.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CVEditorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note, size: 24),
                      label: const Text('Launch CV Editor'),
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

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.edit_note_rounded,
                  title: 'CV Editor',
                  subtitle: 'Create & Edit your CV',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CVEditorScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'My Dashboard',
                  subtitle: 'Manage saved CVs',
                  isComingSoon: true,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.style_rounded,
                  title: 'Templates',
                  subtitle: 'Explore layouts',
                  isComingSoon: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Divider(thickness: 0.5),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'Theme & Account',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 10, 80, 137);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: appBarColor,
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Subtle texture
          opacity: isDark ? 0.05 : 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            'SmartCV Builder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Text(
            'Master your career path',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: isComingSoon ? null : onTap,
        enabled: !isComingSoon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: isComingSoon 
          ? Text('Coming Soon', style: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold))
          : Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isComingSoon ? null : Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  IconData _getThemeIcon(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}