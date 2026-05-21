import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/features/editor/presentation/screens/editor_screen.dart';
import 'package:smartcv_builder/features/cover_letter/presentation/providers/cover_letter_provider.dart';
import 'package:smartcv_builder/features/cover_letter/presentation/screens/cover_letter_editor_screen.dart';
import 'package:smartcv_builder/core/utils/responsive.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/models/cover_letter_data.dart';
import 'package:smartcv_builder/features/settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _documentTypeTab = 0; // 0 = Resumes/CVs, 1 = Cover Letters

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
    final clProvider = context.watch<CoverLetterProvider>();

    final savedCVs = provider.savedCVs;
    final savedCoverLetters = clProvider.savedCoverLetters;
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
        appBar: !isDesktop ? AppBar(title: const Text('Dashboard')) : null,
        drawer: !isDesktop ? _buildMobileDrawer(colorScheme) : null,
        bottomNavigationBar: !isDesktop ? _buildBottomNav(colorScheme) : null,
        body: Row(
          children: [
            if (isDesktop) _buildSidebar(colorScheme),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(
                    context,
                    provider,
                    clProvider,
                    theme,
                    colorScheme,
                    savedCVs,
                    savedCoverLetters,
                  ),
                  _buildNewTab(
                    context,
                    provider,
                    clProvider,
                    theme,
                    colorScheme,
                  ),
                  _buildOpenTab(
                    context,
                    provider,
                    clProvider,
                    theme,
                    colorScheme,
                    savedCVs,
                    savedCoverLetters,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    CVProvider provider,
    CoverLetterProvider clProvider,
    ThemeData theme,
    ColorScheme colorScheme,
    List<CVData> savedCVs,
    List<CoverLetterData> savedCoverLetters,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildTemplatesSection(context, provider, clProvider, theme),
          const SizedBox(height: 48),
          _buildRecentTabs(theme, colorScheme),
          const SizedBox(height: 16),
          if (_documentTypeTab == 0) ...[
            if (savedCVs.isEmpty)
              _buildEmptyState(colorScheme, provider)
            else
              _buildRecentList(savedCVs, provider, theme, colorScheme),
          ] else ...[
            if (savedCoverLetters.isEmpty)
              _buildEmptyCoverLetterState(colorScheme, clProvider)
            else
              _buildRecentCoverLetterList(
                savedCoverLetters,
                clProvider,
                theme,
                colorScheme,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewTab(
    BuildContext context,
    CVProvider provider,
    CoverLetterProvider clProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Document',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTemplatesSection(
                    context,
                    provider,
                    clProvider,
                    theme,
                    fullHeight: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenTab(
    BuildContext context,
    CVProvider provider,
    CoverLetterProvider clProvider,
    ThemeData theme,
    ColorScheme colorScheme,
    List<CVData> savedCVs,
    List<CoverLetterData> savedCoverLetters,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Documents',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildRecentTabs(theme, colorScheme),
          const SizedBox(height: 24),
          if (_documentTypeTab == 0) ...[
            if (savedCVs.isEmpty)
              _buildEmptyState(colorScheme, provider)
            else
              Expanded(
                child: SingleChildScrollView(
                  child: _buildRecentList(
                    savedCVs,
                    provider,
                    theme,
                    colorScheme,
                  ),
                ),
              ),
          ] else ...[
            if (savedCoverLetters.isEmpty)
              _buildEmptyCoverLetterState(colorScheme, clProvider)
            else
              Expanded(
                child: SingleChildScrollView(
                  child: _buildRecentCoverLetterList(
                    savedCoverLetters,
                    clProvider,
                    theme,
                    colorScheme,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar(ColorScheme colorScheme) {
    return Container(
      width: 80,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildSidebarItem(Icons.home_outlined, Icons.home, 'Home', 0, colorScheme),
          _buildSidebarItem(
            Icons.add_circle_outline,
            Icons.add_circle,
            'New',
            1,
            colorScheme,
          ),
          _buildSidebarItem(
            Icons.folder_open_outlined,
            Icons.folder_open,
            'My Docs',
            2,
            colorScheme,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
            border: isSelected
                ? const Border(left: BorderSide(color: Colors.white, width: 4))
                : null,
          ),
        child: Column(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white70,
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
          const DrawerHeader(
            child: Center(
              child: Text(
                'SmartCV',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: _selectedIndex == 0,
            onTap: () => _onTabTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('New'),
            selected: _selectedIndex == 1,
            onTap: () => _onTabTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('My Documents'),
            selected: _selectedIndex == 2,
            onTap: () => _onTabTapped(2),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
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
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'New',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_open_outlined),
          activeIcon: Icon(Icons.folder_open),
          label: 'My Docs',
        ),
      ],
    );
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Close drawer
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
  final colorScheme = Theme.of(context).colorScheme;
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      icon: Icon(
        Icons.exit_to_app_rounded,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
      title: const Text(
        'Exit SmartCV?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to exit the app?\nAll your work is saved automatically.',
        textAlign: TextAlign.center,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Stay'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Exit'),
        ),
      ],
    ),
  ) ?? false;
}

  Widget _buildRecentTabs(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildTabItem('Resumes', _documentTypeTab == 0, colorScheme, () {
          setState(() => _documentTypeTab = 0);
        }),
        const SizedBox(width: 24),
        _buildTabItem('Cover Letters', _documentTypeTab == 1, colorScheme, () {
          setState(() => _documentTypeTab = 1);
        }),
      ],
    );
  }

  Widget _buildTabItem(
    String label,
    bool isSelected,
    ColorScheme colorScheme,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              color: colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildTemplatesSection(
    BuildContext context,
    CVProvider provider,
    CoverLetterProvider clProvider,
    ThemeData theme, {
    bool fullHeight = false,
  }) {
    final cvTemplates = [
      {'id': 'blank', 'name': 'Blank Resume', 'icon': Icons.add},
      {'id': 'default', 'name': 'Simple CV', 'icon': Icons.article},
      {'id': 'modern', 'name': 'Modern Resume', 'icon': Icons.dashboard},
      {'id': 'executive', 'name': 'Executive', 'icon': Icons.business_center},
      {'id': 'creative', 'name': 'Creative', 'icon': Icons.palette},
      {'id': 'metro', 'name': 'Metro Style', 'icon': Icons.grid_view},
    ];

    final clTemplates = [
      {'id': 'blank', 'name': 'Blank Letter', 'icon': Icons.add},
      {'id': 'default', 'name': 'Simple Layout', 'icon': Icons.article},
      {'id': 'modern', 'name': 'Modern Layout', 'icon': Icons.dashboard},
      {
        'id': 'executive',
        'name': 'Executive Layout',
        'icon': Icons.business_center,
      },
      {'id': 'creative', 'name': 'Creative Layout', 'icon': Icons.palette},
      {'id': 'metro', 'name': 'Metro Layout', 'icon': Icons.grid_view},
    ];

    if (fullHeight) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resume Templates',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: cvTemplates.length,
            itemBuilder: (context, index) => _buildTemplateCard(
              context,
              provider,
              clProvider,
              cvTemplates[index],
              false,
            ),
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              const Icon(Icons.mail, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cover Letter Layouts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: clTemplates.length,
            itemBuilder: (context, index) => _buildTemplateCard(
              context,
              provider,
              clProvider,
              clTemplates[index],
              true,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.keyboard_arrow_down, size: 20),
            const SizedBox(width: 4),
            Text(
              'Quick Document Creator',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Resumes:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cvTemplates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildTemplateCard(
              context,
              provider,
              clProvider,
              cvTemplates[index],
              false,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cover Letters:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clTemplates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildTemplateCard(
              context,
              provider,
              clProvider,
              clTemplates[index],
              true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    CVProvider provider,
    CoverLetterProvider clProvider,
    Map<String, dynamic> template,
    bool isCoverLetter,
  ) {
    final isBlank = template['id'] == 'blank';
    return GestureDetector(
      onTap: () {
        if (isCoverLetter) {
          clProvider.createNewCoverLetter();
          if (!isBlank) {
            clProvider.updateStyling(templateId: template['id'] as String);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoverLetterEditorScreen()),
          );
        } else {
          if (isBlank) {
            provider.createNewCV();
          } else {
            provider.changeTemplate(template['id'] as String);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CVEditorScreen()),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isBlank
                ? Center(
                    child: Icon(
                      Icons.add,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  )
                : _buildTemplateMiniPreview(
                    template['id'] as String,
                    isCoverLetter: isCoverLetter,
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 130,
            child: Text(
              template['name'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateMiniPreview(String id, {bool isCoverLetter = false}) {
    if (isCoverLetter) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock Date/Sender
            Container(
              height: 4,
              width: 30,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              margin: const EdgeInsets.only(bottom: 6),
            ),
            // Mock Recipient
            Container(
              height: 4,
              width: 50,
               color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
              margin: const EdgeInsets.only(bottom: 10),
            ),
            // Mock letter paragraphs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  4,
                  (i) => Container(
                    height: 3,
                    width: (i == 3) ? 40 : double.infinity,
                    margin: const EdgeInsets.only(bottom: 4),
                    color: Colors.grey.shade100,
                  ),
                ),
              ),
            ),
            // Mock sign off
            Container(height: 4, width: 25, color: Colors.grey.shade300),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(height: 12, color: Colors.blue.shade800),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (id == 'modern' || id == 'creative') ...[
                  Container(width: 25, color: Colors.blue.shade50),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      6,
                      (i) => Container(
                        height: 4,
                        width: (i % 3 == 0)
                            ? double.infinity
                            : (i % 2 == 0)
                            ? 50
                            : 25,
                        margin: const EdgeInsets.only(bottom: 6),
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentList(
    List<CVData> savedCVs,
    CVProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Text('Name', style: theme.textTheme.bodySmall),
              ),
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
              leading: Icon(Icons.description, color: colorScheme.primary),
              title: Text(
                cv.pdfFileName.isNotEmpty
                    ? cv.pdfFileName
                    : (cv.personalInfo.fullName.isEmpty
                          ? 'Untitled CV'
                          : cv.personalInfo.fullName),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CVEditorScreen()),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete CV'),
                        content: const Text(
                          'Are you sure you want to delete this CV? This action cannot be undone.',
                        ),
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
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CVEditorScreen()),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentCoverLetterList(
    List<CoverLetterData> savedCoverLetters,
    CoverLetterProvider clProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final cvProv = context.read<CVProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Text('Document Name', style: theme.textTheme.bodySmall),
              ),
              Expanded(child: Text('Edited', style: theme.textTheme.bodySmall)),
              const SizedBox(width: 100),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedCoverLetters.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cl = savedCoverLetters[index];
            final linkedCv = cl.linkedCvId != null
                ? cvProv.savedCVs.firstWhere(
                    (cv) => cv.id == cl.linkedCvId,
                    orElse: () => CVData(id: ''),
                  )
                : null;
            final isLinked = linkedCv != null && linkedCv.id.isNotEmpty;

            return ListTile(
              leading: Icon(Icons.mail_outline, color: colorScheme.primary),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      cl.pdfFileName.isNotEmpty
                          ? cl.pdfFileName
                          : 'Untitled Cover Letter',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLinked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link,
                            size: 10,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Linked',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                'Last edited: ${cl.lastModifiedFormatted}${isLinked ? " (Synced: ${linkedCv.pdfFileName})" : ""}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    clProvider.loadCoverLetter(cl.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CoverLetterEditorScreen(),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Cover Letter'),
                        content: const Text(
                          'Are you sure you want to delete this Cover Letter? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              clProvider.deleteCoverLetter(cl.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
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
                clProvider.loadCoverLetter(cl.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoverLetterEditorScreen(),
                  ),
                );
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
          Icon(
            Icons.description_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
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

  Widget _buildEmptyCoverLetterState(
    ColorScheme colorScheme,
    CoverLetterProvider clProvider,
  ) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.mail_outline, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),),
          const SizedBox(height: 16),
          const Text('No recent cover letters'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              clProvider.createNewCoverLetter();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CoverLetterEditorScreen(),
                ),
              );
            },
            child: const Text('Create Cover Letter'),
          ),
        ],
      ),
    );
  }
}
