import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/features/editor/presentation/screens/editor_screen.dart';
import 'package:smartcv_builder/core/utils/responsive.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<CVProvider>();
    final savedCVs = provider.savedCVs;
    final isDesktop = Responsive.isDesktop(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: !isDesktop
            ? AppBar(
                title: const Text('Dashboard'),
              )
            : null,
        // Use a Drawer for sidebar on mobile, NavigationRail on desktop
        drawer: !isDesktop ? _buildMobileDrawer(colorScheme) : null,
        bottomNavigationBar: !isDesktop ? _buildBottomNav(colorScheme) : null,
        body: Row(
          children: [
            if (isDesktop) _buildSidebar(colorScheme),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(context, provider, theme, colorScheme, savedCVs),
                  _buildNewTab(context, provider, theme, colorScheme),
                  _buildOpenTab(context, provider, theme, colorScheme, savedCVs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, CVProvider provider, ThemeData theme, ColorScheme colorScheme, List<CVData> savedCVs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildTemplatesSection(context, provider, theme),
          const SizedBox(height: 48),
          _buildRecentTabs(theme, colorScheme),
          const SizedBox(height: 16),
          if (savedCVs.isEmpty)
            _buildEmptyState(colorScheme, provider)
          else
            _buildRecentList(savedCVs, provider, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildNewTab(BuildContext context, CVProvider provider, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(child: _buildTemplatesSection(context, provider, theme, fullHeight: true)),
        ],
      ),
    );
  }

  Widget _buildOpenTab(BuildContext context, CVProvider provider, ThemeData theme, ColorScheme colorScheme, List<CVData> savedCVs) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My CVs', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text('Recent', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          if (savedCVs.isEmpty)
            _buildEmptyState(colorScheme, provider)
          else
            Expanded(child: SingleChildScrollView(child: _buildRecentList(savedCVs, provider, theme, colorScheme))),
        ],
      ),
    );
  }

  Widget _buildSidebar(ColorScheme colorScheme) {
    return Container(
      width: 80,
      color: Colors.blue.shade800,
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildSidebarItem(Icons.home_outlined, Icons.home, 'Home', 0),
          _buildSidebarItem(Icons.add_circle_outline, Icons.add_circle, 'New', 1),
          _buildSidebarItem(Icons.folder_open_outlined, Icons.folder_open, 'My CVs', 2),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: Colors.white, width: 4))
              : null,
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Center(child: Text('SmartCV', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), selected: _selectedIndex == 0, onTap: () => _onTabTapped(0)),
          ListTile(leading: const Icon(Icons.add_circle), title: const Text('New'), selected: _selectedIndex == 1, onTap: () => _onTabTapped(1)),
          ListTile(leading: const Icon(Icons.folder_open), title: const Text('My CVs'), selected: _selectedIndex == 2, onTap: () => _onTabTapped(2)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ColorScheme colorScheme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'New'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), activeIcon: Icon(Icons.folder_open), label: 'My CVs'),
      ],
    );
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Close drawer
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(
              Icons.exit_to_app_rounded,
              size: 40,
              color: Colors.blueGrey,
            ),
            title: const Text(
              'Exit SmartCV?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to exit the app?\nAll your work is saved automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Stay'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildTemplatesSection(BuildContext context, CVProvider provider, ThemeData theme, {bool fullHeight = false}) {
    final templates = [
      {'id': 'blank', 'name': 'Blank document', 'icon': Icons.add},
      {'id': 'default', 'name': 'Simple CV', 'icon': Icons.article},
      {'id': 'modern', 'name': 'Modern Resume', 'icon': Icons.dashboard},
      {'id': 'executive', 'name': 'Executive', 'icon': Icons.business_center},
      {'id': 'creative', 'name': 'Creative', 'icon': Icons.palette},
      {'id': 'metro', 'name': 'Metro Style', 'icon': Icons.grid_view},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fullHeight)
          Row(
            children: [
              const Icon(Icons.keyboard_arrow_down, size: 20),
              const SizedBox(width: 4),
              Text(
                'Templates',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (fullHeight)
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.75,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) => _buildTemplateCard(context, provider, templates[index]),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 24),
              itemBuilder: (context, index) => _buildTemplateCard(context, provider, templates[index]),
            ),
          ),
        if (!fullHeight) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Templates',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Colors.blue.shade300,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTemplateCard(BuildContext context, CVProvider provider, Map<String, dynamic> template) {
    final isBlank = template['id'] == 'blank';
    return GestureDetector(
      onTap: () {
        if (isBlank) {
          provider.createNewCV();
        } else {
          provider.changeTemplate(template['id'] as String);
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CVEditorScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: isBlank 
              ? Center(child: Icon(Icons.add, size: 48, color: Colors.grey.shade300))
              : _buildTemplateMiniPreview(template['id'] as String),
          ),
          const SizedBox(height: 8),
          Text(
            template['name'] as String,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateMiniPreview(String id) {
    return Column(
      children: [
        Container(height: 15, color: Colors.blue.shade800),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (id == 'modern' || id == 'creative') ...[
                  Container(width: 30, color: Colors.blue.shade50),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(8, (i) => Container(
                      height: 4,
                      width: (i % 3 == 0) ? double.infinity : (i % 2 == 0) ? 60 : 30,
                      margin: const EdgeInsets.only(bottom: 6),
                      color: Colors.grey.shade100,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTabs(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildTabItem('Recent', true, colorScheme),
      ],
    );
  }

  Widget _buildTabItem(String label, bool isSelected, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 40,
            color: Colors.blue.shade800,
          ),
      ],
    );
  }

  Widget _buildRecentList(List<CVData> savedCVs, CVProvider provider, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(flex: 3, child: Text('Name', style: theme.textTheme.bodySmall)),
              Expanded(child: Text('Edited', style: theme.textTheme.bodySmall)),
              const SizedBox(width: 100),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedCVs.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cv = savedCVs[index];
            return ListTile(
              leading: Icon(Icons.description, color: Colors.blue.shade800),
              title: Text(
                cv.pdfFileName.isNotEmpty ? cv.pdfFileName : (cv.personalInfo.fullName.isEmpty ? 'Untitled CV' : cv.personalInfo.fullName),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Last edited: ${cv.lastModifiedFormatted}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    provider.loadCV(cv.id);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CVEditorScreen()));
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete CV'),
                        content: const Text('Are you sure you want to delete this CV? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteCV(cv.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                provider.loadCV(cv.id);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CVEditorScreen()));
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, CVProvider provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No recent documents'),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => provider.loadCV('example_john_doe'),
            child: const Text('Load Example CV'),
          ),
        ],
      ),
    );
  }
}
