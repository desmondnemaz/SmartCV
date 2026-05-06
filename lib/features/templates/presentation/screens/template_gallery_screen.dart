import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/features/editor/presentation/screens/editor_screen.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<CVProvider>();
    final currentTemplate = provider.cvData.templateId;

    final templates = [
      _TemplateInfo(
        id: 'default',
        name: 'Simple',
        description: 'Clean and traditional layout, perfect for academic and classic professional roles.',
        icon: Icons.article_outlined,
      ),
      _TemplateInfo(
        id: 'modern',
        name: 'Modern',
        description: 'Stylish two-column design with a prominent header, great for tech and creative industries.',
        icon: Icons.dashboard_outlined,
      ),
      _TemplateInfo(
        id: 'metro',
        name: 'Metro',
        description: 'Professional single-column layout with bold dividers and high readability.',
        icon: Icons.grid_view_outlined,
      ),
      _TemplateInfo(
        id: 'executive',
        name: 'Executive',
        description: 'Sophisticated and elegant design tailored for senior management and leadership roles.',
        icon: Icons.business_center_outlined,
      ),
      _TemplateInfo(
        id: 'creative',
        name: 'Creative',
        description: 'Unique sidebar-driven layout with visual flair, ideal for designers and artists.',
        icon: Icons.palette_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Template'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select your style',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Each template is professionally designed to ensure your CV stands out.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final template = templates[index];
                  final isSelected = currentTemplate == template.id;

                  return _TemplateCard(
                    template: template,
                    isSelected: isSelected,
                    onSelect: () {
                      provider.changeTemplate(template.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CVEditorScreen()),
                      );
                    },
                  );
                },
                childCount: templates.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _TemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  _TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class _TemplateCard extends StatefulWidget {
  final _TemplateInfo template;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: widget.isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: widget.onSelect,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    child: _buildLayoutPreview(widget.template.id, widget.isSelected, colorScheme),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.template.name,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (widget.isSelected)
                            Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.template.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onSelect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.isSelected ? colorScheme.primary : null,
                            side: widget.isSelected ? BorderSide(color: colorScheme.primary) : null,
                          ),
                          child: Text(widget.isSelected ? 'Selected' : 'Use Template'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutPreview(String id, bool isSelected, ColorScheme colorScheme) {
    final primary = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    final secondary = isSelected ? colorScheme.primary.withValues(alpha: 0.2) : colorScheme.onSurfaceVariant.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            // Body layout simulation
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (id == 'modern' || id == 'creative') ...[
                      // Sidebar
                      Container(
                        width: 30,
                        decoration: BoxDecoration(
                          color: secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    // Main content lines
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          10,
                          (i) => Container(
                            height: 4,
                            width: (i % 4 == 0) ? double.infinity : (i % 2 == 0) ? 80 : 40,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
