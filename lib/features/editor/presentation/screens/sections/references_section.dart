import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/components/expandable_section_title.dart';

class ReferencesSection extends StatelessWidget {
  const ReferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Reference>, SectionTitles)>(
      selector: (_, p) => (List.from(p.cvData.references), p.cvData.sectionTitles),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final provider = context.read<CVProvider>();

        return ExpansionTile(
          leading: const Icon(Icons.people),
          title: ExpandableSectionTitle(
            sectionTitle: titles.references,
            isVisibleOnCv: titles.showReferences,
            onTitleRenamed: (val) =>
                provider.updateSectionTitles(titles.copyWith(references: val)),
            onVisibilityToggled: () => provider.updateSectionTitles(
                titles.copyWith(showReferences: !titles.showReferences)),
            onSectionRemoved: () => provider.removeSection('references'),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reference = entry.value;
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
                              const Text('Reference',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => provider.removeReference(index),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: reference.name,
                            decoration: const InputDecoration(labelText: 'Name', isDense: true),
                            onChanged: (val) { reference.name = val; provider.updateReference(index, reference); },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: reference.position,
                            decoration: const InputDecoration(labelText: 'Position', isDense: true),
                            onChanged: (val) { reference.position = val; provider.updateReference(index, reference); },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: reference.company,
                            decoration: const InputDecoration(labelText: 'Company/Organization', isDense: true),
                            onChanged: (val) { reference.company = val; provider.updateReference(index, reference); },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: reference.email,
                                  decoration: const InputDecoration(labelText: 'Email', isDense: true),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (val) { reference.email = val; provider.updateReference(index, reference); },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: reference.phone,
                                  decoration: const InputDecoration(labelText: 'Phone', isDense: true),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (val) { reference.phone = val; provider.updateReference(index, reference); },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addReference(Reference()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reference'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
