import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Certification>, SectionTitles, bool)>(
      selector: (_, p) => (List.from(p.cvData.certifications), p.cvData.sectionTitles, p.cvData.pageBreaks.contains('certifications')),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final startsOnNewPage = data.$3;
        final provider = context.read<CVProvider>();
        return ExpansionTile(
          leading: const Icon(Icons.verified),
          title: ExpandableSectionTitle(
            sectionTitle: titles.certifications,
            isVisibleOnCv: titles.showCertifications,
            startsOnNewPage: startsOnNewPage,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(certifications: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showCertifications: !titles.showCertifications));
            },
            onToggleNewPage: () {
              provider.togglePageBreak('certifications');
            },
            onSectionRemoved: () {
              provider.removeSection('certifications');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cert = entry.value;
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Certification', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  provider.removeCertification(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: cert.title,
                            decoration: const InputDecoration(labelText: 'Certification Title', isDense: true),
                            onChanged: (val) {
                              cert.title = val;
                              provider.updateCertification(index, cert);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: cert.issuer,
                            decoration: const InputDecoration(labelText: 'Issuing Organization', isDense: true),
                            onChanged: (val) {
                              cert.issuer = val;
                              provider.updateCertification(index, cert);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: cert.date,
                                  decoration: const InputDecoration(labelText: 'Date (Year or MM/YYYY)', isDense: true),
                                  onChanged: (val) {
                                    cert.date = val;
                                    provider.updateCertification(index, cert);
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                children: [
                                  const Text('Status', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                                  Switch(
                                    value: cert.isCompleted,
                                    onChanged: (val) {
                                      cert.isCompleted = val;
                                      provider.updateCertification(index, cert);
                                    },
                                  ),
                                  Text(cert.isCompleted ? 'Completed' : 'In Progress', style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Description (Optional)', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichTextEditorField(
                            initialValue: cert.description,
                            onChanged: (val) {
                              cert.description = val;
                              provider.updateCertification(index, cert);
                            },
                            height: 100,
                            placeholder: 'Additional details...',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.addCertification(Certification());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Certification'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
