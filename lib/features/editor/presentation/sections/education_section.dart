import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Education>, SectionTitles)>(
      selector: (_, p) => (List.from(p.cvData.education), p.cvData.sectionTitles),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final provider = context.read<CVProvider>();
        return ExpansionTile(
          leading: const Icon(Icons.school),
          title: ExpandableSectionTitle(
            sectionTitle: titles.education,
            isVisibleOnCv: titles.showEducation,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(education: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showEducation: !titles.showEducation));
            },
            onSectionRemoved: () {
              provider.removeSection('education');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
               children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ed = entry.value;
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
                              const Text('Education', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  provider.removeEducation(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: ed.institution,
                            decoration: const InputDecoration(labelText: 'Institution', isDense: true),
                            onChanged: (val) {
                              ed.institution = val;
                              provider.updateEducation(index, ed);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: ed.degree,
                            decoration: const InputDecoration(labelText: 'Degree', isDense: true),
                            onChanged: (val) {
                              ed.degree = val;
                              provider.updateEducation(index, ed);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: ed.startDate,
                                  decoration: const InputDecoration(labelText: 'Start Date', isDense: true),
                                  onChanged: (val) {
                                    ed.startDate = val;
                                    provider.updateEducation(index, ed);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: ed.endDate,
                                  decoration: const InputDecoration(labelText: 'End Date', isDense: true),
                                  onChanged: (val) {
                                    ed.endDate = val;
                                    provider.updateEducation(index, ed);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Description', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichTextEditorField(
                            initialValue: ed.description,
                            onChanged: (val) {
                              ed.description = val;
                              provider.updateEducation(index, ed);
                            },
                            height: 120,
                            placeholder: 'Describe your studies...',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.addEducation(Education());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
