import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import '../components/expandable_section_title.dart';
import '../components/rich_text_editor_field.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CVProvider, (List<Project>, SectionTitles)>(
      selector: (_, p) => (List.from(p.cvData.projects), p.cvData.sectionTitles),
      builder: (context, data, _) {
        final list = data.$1;
        final titles = data.$2;
        final provider = context.read<CVProvider>();
        return ExpansionTile(
          leading: const Icon(Icons.rocket_launch),
          title: ExpandableSectionTitle(
            sectionTitle: titles.projects,
            isVisibleOnCv: titles.showProjects,
            onTitleRenamed: (newTitle) {
              provider.updateSectionTitles(titles.copyWith(projects: newTitle));
            },
            onVisibilityToggled: () {
              provider.updateSectionTitles(titles.copyWith(showProjects: !titles.showProjects));
            },
            onSectionRemoved: () {
              provider.removeSection('projects');
            },
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final project = entry.value;
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
                              const Text('Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  provider.removeProject(index);
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: project.title,
                            decoration: const InputDecoration(labelText: 'Project Title', isDense: true),
                            onChanged: (val) {
                              project.title = val;
                              provider.updateProject(index, project);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: project.link,
                            decoration: const InputDecoration(labelText: 'Project Link / URL (Optional)', isDense: true),
                            onChanged: (val) {
                              project.link = val;
                              provider.updateProject(index, project);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: project.startDate,
                                  decoration: const InputDecoration(labelText: 'Start Date', isDense: true),
                                  onChanged: (val) {
                                    project.startDate = val;
                                    provider.updateProject(index, project);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: project.endDate,
                                  decoration: const InputDecoration(labelText: 'End Date', isDense: true),
                                  onChanged: (val) {
                                    project.endDate = val;
                                    provider.updateProject(index, project);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Description', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichTextEditorField(
                            initialValue: project.description,
                            onChanged: (val) {
                              project.description = val;
                              provider.updateProject(index, project);
                            },
                            height: 120,
                            placeholder: 'Describe your project...',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    provider.addProject(Project());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
