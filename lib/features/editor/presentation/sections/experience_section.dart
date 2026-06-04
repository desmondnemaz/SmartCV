import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Experience>, SectionTitles, bool)>(
      selector: (_, p) => (List.from(p.cvData.experience), p.cvData.sectionTitles, p.cvData.pageBreaks.contains('experience')),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final startsOnNewPage = data.$3;
        final provider = context.read<CVProvider>();
        
        return ExpansionTile(
          leading: const Icon(Icons.work),
          title: ExpandableSectionTitle(
            sectionTitle: titles.experience,
            isVisibleOnCv: titles.showExperience,
            startsOnNewPage: startsOnNewPage,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(experience: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showExperience: !titles.showExperience));
            },
            onToggleNewPage: () {
              provider.togglePageBreak('experience');
            },
            onSectionRemoved: () {
              provider.removeSection('experience');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exp = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  provider.removeExperience(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: exp.position,
                            decoration: const InputDecoration(labelText: 'Job Title', isDense: true),
                            onChanged: (val) {
                              exp.position = val;
                              provider.updateExperience(index, exp);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: exp.company,
                            decoration: const InputDecoration(labelText: 'Company', isDense: true),
                            onChanged: (val) {
                              exp.company = val;
                              provider.updateExperience(index, exp);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: exp.startDate,
                                  decoration: const InputDecoration(labelText: 'Start', isDense: true),
                                  onChanged: (val) {
                                    exp.startDate = val;
                                    provider.updateExperience(index, exp);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: exp.endDate,
                                  decoration: const InputDecoration(labelText: 'End', isDense: true),
                                  onChanged: (val) {
                                    exp.endDate = val;
                                    provider.updateExperience(index, exp);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Description', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichTextEditorField(
                            initialValue: exp.description,
                            onChanged: (val) {
                              exp.description = val;
                              provider.updateExperience(index, exp);
                            },
                            height: 120,
                            placeholder: 'Describe your role and achievements...',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.addExperience(Experience());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
