import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/components/expandable_section_title.dart';
import 'package:smartcv_builder/features/editor/presentation/components/rich_text_editor_field.dart';

class CustomSectionWidget extends StatelessWidget {
  final String id;
  const CustomSectionWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, CustomSection?>(
      key: ValueKey(id),
      selector: (_, p) => p.cvData.customSections
          .cast<CustomSection?>()
          .firstWhere((s) => s?.id == id, orElse: () => null),
      builder: (context, section, _) {
        final provider = context.read<CVProvider>();
        if (section == null) return const SizedBox.shrink();

        return ExpansionTile(
          leading: const Icon(Icons.dashboard_customize),
          title: ExpandableSectionTitle(
            sectionTitle: section.title,
            isVisibleOnCv: section.isVisible,
            onTitleRenamed: (val) =>
                provider.updateCustomSection(id, section.copyWith(title: val)),
            onVisibilityToggled: () =>
                provider.updateCustomSection(id, section.copyWith(isVisible: !section.isVisible)),
            onSectionRemoved: () => provider.removeCustomSection(id),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            const Text('Description',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RichTextEditorField(
              key: ValueKey('custom_$id'),
              initialValue: section.description,
              height: 250,
              placeholder: 'Describe this section...',
              onChanged: (val) {
                section.description = val;
                provider.updateCustomSection(id, section);
              },
            ),
          ],
        );
      },
    );
  }
}
