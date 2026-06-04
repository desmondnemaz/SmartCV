import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class CustomSectionWidget extends StatelessWidget {
  final String id;

  const CustomSectionWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (CustomSection?, bool)>(
      selector: (context, p) {
        final section = p.cvData.customSections.cast<CustomSection?>().firstWhere((s) => s?.id == id, orElse: () => null);
        return (section, p.cvData.pageBreaks.contains(id));
      },
      builder: (context, data, _) {
        final section = data.$1;
        final startsOnNewPage = data.$2;
        final provider = context.read<CVProvider>();
        
        if (section == null) return const SizedBox.shrink();

        return ExpansionTile(
          leading: const Icon(Icons.dashboard_customize),
          title: ExpandableSectionTitle(
            sectionTitle: section.title,
            isVisibleOnCv: section.isVisible,
            startsOnNewPage: startsOnNewPage,
            onTitleRenamed: (newTitle) {
              provider.updateCustomSection(id, section.copyWith(title: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateCustomSection(id, section.copyWith(isVisible: !section.isVisible));
            },
            onToggleNewPage: () {
              provider.togglePageBreak(section.id);
            },
            onSectionRemoved: () {
              provider.removeCustomSection(id);
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RichTextEditorField(
                  initialValue: section.description,
                  onChanged: (val) {
                    section.description = val;
                    provider.updateCustomSection(id, section);
                  },
                  height: 250,
                  placeholder: 'Describe this section...',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
