import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/components/expandable_section_title.dart';
import 'package:smartcv_builder/features/editor/presentation/components/rich_text_editor_field.dart';

class ProfessionalSummarySection extends StatelessWidget {
  const ProfessionalSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (SectionTitles, String)>(
      selector: (_, p) => (p.cvData.sectionTitles, p.cvData.personalInfo.profileSummary),
      builder: (context, data, _) {
        final titles = data.$1;
        final summary = data.$2;
        final provider = context.read<CVProvider>();

        return ExpansionTile(
          leading: const Icon(Icons.description),
          title: ExpandableSectionTitle(
            sectionTitle: titles.professionalSummary,
            isVisibleOnCv: titles.showProfessionalSummary,
            onTitleRenamed: (val) =>
                provider.updateSectionTitles(titles.copyWith(professionalSummary: val)),
            onVisibilityToggled: () => provider.updateSectionTitles(
                titles.copyWith(showProfessionalSummary: !titles.showProfessionalSummary)),
            onSectionRemoved: () => provider.removeSection('professionalSummary'),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            const Text('Summary',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RichTextEditorField(
              key: const ValueKey('professionalSummary'),
              initialValue: summary,
              height: 150,
              placeholder: 'Write your professional summary...',
              onChanged: (val) {
                final info = provider.cvData.personalInfo;
                provider.updatePersonalInfo(PersonalInfo(
                  jobTitle: info.jobTitle,
                  headerAlignment: info.headerAlignment,
                  fields: info.fields,
                  profileSummary: val,
                  showNameAsHeader: info.showNameAsHeader,
                ));
              },
            ),
          ],
        );
      },
    );
  }
}
