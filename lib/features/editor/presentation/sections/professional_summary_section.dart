import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class ProfessionalSummarySection extends StatelessWidget {
  const ProfessionalSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (SectionTitles, bool)>(
      selector: (_, p) => (p.cvData.sectionTitles, p.cvData.pageBreaks.contains('professionalSummary')),
      builder: (context, data, _) {
        final titles = data.$1;
        final provider = context.read<CVProvider>();
        
        // Find the actual summary content directly from the provider without passing the global controller.
        // But wait! The original implementation used a single global `_summaryQuillCtrl` 
        // to handle live updates in personalInfo without jumping. We should use RichTextEditorField.
        final summaryContent = provider.cvData.personalInfo.profileSummary;

        return ExpansionTile(
          leading: const Icon(Icons.description),
          title: ExpandableSectionTitle(
            sectionTitle: titles.professionalSummary,
            isVisibleOnCv: titles.showProfessionalSummary,
            startsOnNewPage: provider.cvData.pageBreaks.contains('professionalSummary'),
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(professionalSummary: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showProfessionalSummary: !titles.showProfessionalSummary));
            },
            onToggleNewPage: () {
              provider.togglePageBreak('professionalSummary');
            },
            onSectionRemoved: () {
              provider.removeSection('professionalSummary');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RichTextEditorField(
                  initialValue: summaryContent,
                  onChanged: (val) {
                    final currentInfo = provider.cvData.personalInfo;
                    provider.updatePersonalInfo(
                      PersonalInfo(
                        jobTitle: currentInfo.jobTitle,
                        headerAlignment: currentInfo.headerAlignment,
                        fields: currentInfo.fields,
                        profileSummary: val,
                        showNameAsHeader: currentInfo.showNameAsHeader,
                      )
                    );
                  },
                  height: 150,
                  placeholder: 'Write your professional summary...',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
