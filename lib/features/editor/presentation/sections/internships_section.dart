import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class InternshipsSection extends StatelessWidget {
  const InternshipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Internship>, SectionTitles)>(
      selector: (_, p) => (List.from(p.cvData.internships), p.cvData.sectionTitles),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final provider = context.read<CVProvider>();
        
        return ExpansionTile(
          leading: const Icon(Icons.history_edu),
          title: ExpandableSectionTitle(
            sectionTitle: titles.internships,
            isVisibleOnCv: titles.showInternships,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(internships: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showInternships: !titles.showInternships));
            },
            onSectionRemoved: () {
              provider.removeSection('internships');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final internship = entry.value;
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
                              const Text('Internship', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  provider.removeInternship(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: internship.position,
                            decoration: const InputDecoration(labelText: 'Internship Role', isDense: true),
                            onChanged: (val) {
                              internship.position = val;
                              provider.updateInternship(index, internship);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: internship.company,
                            decoration: const InputDecoration(labelText: 'Company', isDense: true),
                            onChanged: (val) {
                              internship.company = val;
                              provider.updateInternship(index, internship);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: internship.startDate,
                                  decoration: const InputDecoration(labelText: 'Start Date', isDense: true),
                                  onChanged: (val) {
                                    internship.startDate = val;
                                    provider.updateInternship(index, internship);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: internship.endDate,
                                  decoration: const InputDecoration(labelText: 'End Date', isDense: true),
                                  onChanged: (val) {
                                    internship.endDate = val;
                                    provider.updateInternship(index, internship);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Description', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichTextEditorField(
                            initialValue: internship.description,
                            onChanged: (val) {
                              internship.description = val;
                              provider.updateInternship(index, internship);
                            },
                            height: 120,
                            placeholder: 'Describe your internship...',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.addInternship(Internship());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Internship'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
