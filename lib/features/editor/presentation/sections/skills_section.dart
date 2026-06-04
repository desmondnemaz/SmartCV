import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Skill>, SectionTitles, bool)>(
      selector: (_, p) => (List.from(p.cvData.skills), p.cvData.sectionTitles, p.cvData.pageBreaks.contains('skills')),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final startsOnNewPage = data.$3;
        final provider = context.read<CVProvider>();
        return ExpansionTile(
          leading: const Icon(Icons.star),
          title: ExpandableSectionTitle(
            sectionTitle: titles.skills,
            isVisibleOnCv: titles.showSkills,
            startsOnNewPage: startsOnNewPage,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(skills: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showSkills: !titles.showSkills));
            },
            onToggleNewPage: () {
              provider.togglePageBreak('skills');
            },
            onSectionRemoved: () {
              provider.removeSection('skills');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: skill.name,
                            decoration: const InputDecoration(labelText: 'Skill', isDense: true),
                            onChanged: (val) {
                              skill.name = val;
                              provider.updateSkill(index, skill);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => provider.removeSkill(index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addSkill(Skill()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Skill'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
