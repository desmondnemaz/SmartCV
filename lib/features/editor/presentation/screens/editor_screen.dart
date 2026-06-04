import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/core/utils/responsive.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';

import 'package:smartcv_builder/features/editor/presentation/components/preview_section.dart';
import 'sections/experience_section.dart';
import 'sections/education_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/internships_section.dart';
import 'sections/certifications_section.dart';
import 'sections/references_section.dart';
import 'sections/custom_section.dart';
import 'sections/professional_summary_section.dart';

class CVEditorScreen extends StatefulWidget {
  const CVEditorScreen({super.key});

  @override
  State<CVEditorScreen> createState() => _CVEditorScreenState();
}

class _FieldControllerPair {
  final TextEditingController titleCtrl;
  final TextEditingController valueCtrl;
  final bool isCompulsory;

  _FieldControllerPair({
    required this.titleCtrl,
    required this.valueCtrl,
    required this.isCompulsory,
  });

  void dispose() {
    titleCtrl.dispose();
    valueCtrl.dispose();
  }
}



class _CVEditorScreenState extends State<CVEditorScreen> {
  late TextEditingController _jobTitleCtrl;
  String _headerAlignment = 'left';
  bool _showNameAsHeader = false;
  final List<_FieldControllerPair> _fieldControllers = [];
  late TextEditingController _pdfFileNameCtrl;

  @override
  void initState() {
    super.initState();
    final data = context.read<CVProvider>().cvData;
    final info = data.personalInfo;

    
    // Summary quill controller removed
    
    _jobTitleCtrl = TextEditingController(text: info.jobTitle);
    _jobTitleCtrl.addListener(_updatePersonalInfo);
    _headerAlignment = info.headerAlignment;
    _showNameAsHeader = info.showNameAsHeader;

    for (var field in info.fields) {
      _addFieldController(field.title, field.value, field.isCompulsory);
    }

    _pdfFileNameCtrl = TextEditingController(text: data.pdfFileName);
    _pdfFileNameCtrl.addListener(() {
      context.read<CVProvider>().updatePdfFileName(_pdfFileNameCtrl.text);
    });
  }


  void _updatePersonalInfo() {
    final List<CVField> fields = [];
    for (var pair in _fieldControllers) {
      fields.add(CVField(
        title: pair.titleCtrl.text,
        value: pair.valueCtrl.text,
        isCompulsory: pair.isCompulsory,
      ));
    }

    final currentInfo = context.read<CVProvider>().cvData.personalInfo;
    context.read<CVProvider>().updatePersonalInfo(PersonalInfo(
      jobTitle: _jobTitleCtrl.text,
      headerAlignment: _headerAlignment,
      fields: fields,
      profileSummary: currentInfo.profileSummary, // preserved
      showNameAsHeader: _showNameAsHeader,
    ));
  }

  void _addFieldController([String title = '', String value = '', bool isCompulsory = false]) {
    final titleCtrl = TextEditingController(text: title);
    final valueCtrl = TextEditingController(text: value);
    
    titleCtrl.addListener(_updatePersonalInfo);
    valueCtrl.addListener(_updatePersonalInfo);
    
    setState(() {
      _fieldControllers.add(_FieldControllerPair(
        titleCtrl: titleCtrl,
        valueCtrl: valueCtrl,
        isCompulsory: isCompulsory,
      ));
    });
  }

  void _removeFieldController(int index) {
    if (_fieldControllers[index].isCompulsory) return;
    
    setState(() {
      final pair = _fieldControllers.removeAt(index);
      pair.dispose();
    });
    _updatePersonalInfo();
  }

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    for (var pair in _fieldControllers) {
      pair.dispose();
    }
    super.dispose();
  }

  /// Returns true if navigation should proceed (leave), false if staying.
  /// Also handles discard logic internally.
  Future<bool> _confirmLeaveEditor(BuildContext context) async {
    final provider = context.read<CVProvider>();

    // --- EMPTY CV: offer Discard or Keep as Draft ---
    if (provider.isCurrentCVEmpty) {
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.description_outlined, size: 40, color: Colors.blueGrey),
          title: const Text(
            'Empty CV',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This CV has no content yet.\nWould you like to discard it or keep it as a draft?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('editing'),
              child: const Text('Keep Editing'),
            ),
            OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop('draft'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keep as Draft'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Discard'),
          ),
          ],
        ),
      );

      if (choice == 'discard') {
        await provider.discardCurrentCV();
        return true; // pop editor
      } else if (choice == 'draft') {
        await provider.saveCurrentCV();
        return true; // leave, keep saved
      }
      return false; // keep editing
    }

    // --- CV HAS CONTENT: simple leave confirmation ---
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.save_outlined, size: 40, color: Colors.blueGrey),
            title: const Text(
              'Leave Editor?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Your CV is saved automatically.\nYou can return and continue editing anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Keep Editing'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeaveEditor(context);
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(context),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Dashboard',
            onPressed: () async {
              final shouldLeave = await _confirmLeaveEditor(context);
              if (shouldLeave && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (!Responsive.isDesktop(context))
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _showMobilePreview(context),
              ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save CV',
              onPressed: () {
                context.read<CVProvider>().updatePdfFileName(_pdfFileNameCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CV saved successfully'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildEditorForm(),
            ),
            if (Responsive.isDesktop(context))
              const VerticalDivider(width: 1),
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 3,
                child: _buildLivePreview(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildHeaderSection(),
        ),
        Expanded(
          child: Selector<CVProvider, List<String>>(
            selector: (context, provider) => List.from(provider.cvData.sectionOrder),
            builder: (context, order, _) {
              return ReorderableListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  context.read<CVProvider>().reorderSections(oldIndex, newIndex);
                },
                children: [
                  for (int i = 0; i < order.length; i++)
                    Row(
                      key: ValueKey(order[i]),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 14.0, right: 8.0, left: 4.0),
                            child: Icon(Icons.drag_handle, color: Colors.grey),
                          ),
                        ),
                        Expanded(child: _buildSectionByKey(order[i])),
                      ],
                    ),
                  // Section Picker at the bottom of the list
                  Padding(
                    key: const ValueKey('section_picker_spacer'),
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    child: _buildSectionPicker(order),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPicker(List<String> currentOrder) {
    final allPossibleSections = [
      {'key': 'experience', 'label': 'Experience', 'icon': Icons.work},
      {'key': 'education', 'label': 'Education', 'icon': Icons.school},
      {'key': 'skills', 'label': 'Skills', 'icon': Icons.star},
      {'key': 'internships', 'label': 'Internships', 'icon': Icons.work_outline},
      {'key': 'projects', 'label': 'Projects', 'icon': Icons.code},
      {'key': 'certifications', 'label': 'Certifications', 'icon': Icons.verified_outlined},
      {'key': 'references', 'label': 'References', 'icon': Icons.people_outline},
      {'key': 'courses', 'label': 'Courses', 'icon': Icons.book_outlined},
      {'key': 'activities', 'label': 'Extracurricular activities', 'icon': Icons.sports_basketball_outlined},
      {'key': 'qualities', 'label': 'Qualities', 'icon': Icons.lightbulb_outline},
      {'key': 'achievements', 'label': 'Achievements', 'icon': Icons.emoji_events_outlined},
      {'key': 'signature', 'label': 'Signature', 'icon': Icons.edit_note},
      {'key': 'footer', 'label': 'Footer', 'icon': Icons.short_text},
      {'key': 'custom', 'label': 'Custom section', 'icon': Icons.add},
    ];

    // Filter out already added sections (except 'custom' which can be added multiple times)
    final available = allPossibleSections.where((s) {
      if (s['key'] == 'custom') return true;
      return !currentOrder.contains(s['key']);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (available.isNotEmpty) ...[
          const Text('Add Sections', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.map((s) {
              return ActionChip(
                avatar: Icon(s['icon'] as IconData, size: 16),
                label: Text(s['label'] as String),
                onPressed: () {
                  final key = s['key'] as String;
                  final label = s['label'] as String;
                  
                  if (key == 'custom') {
                    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                    context.read<CVProvider>().addCustomSection(CustomSection(id: id));
                    return;
                  }

                  // Standard sections
                  if (['experience', 'education', 'skills', 'internships', 'projects', 'certifications', 'references'].contains(key)) {
                    context.read<CVProvider>().addSection(key);
                  } else {
                    // Create as custom section with a preset title
                    final id = 'custom_${key}_${DateTime.now().millisecondsSinceEpoch}';
                    context.read<CVProvider>().addCustomSection(CustomSection(id: id, title: label));
                  }
                },
                backgroundColor: Colors.white,
                shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionByKey(String key) {
    if (key.startsWith('custom_')) {
      return CustomSectionWidget(id: key);
    }
    switch (key) {
      case 'personalInfo': return _buildPersonalInfoSection();
      case 'professionalSummary': return const ProfessionalSummarySection();
      case 'experience': return const ExperienceSection();
      case 'internships': return const InternshipsSection();
      case 'education': return const EducationSection();
      case 'projects': return const ProjectsSection();
      case 'skills': return const SkillsSection();
      case 'certifications': return const CertificationsSection();
      case 'references': return const ReferencesSection();
      default: return const SizedBox.shrink();
    }
  }


  Widget _buildHeaderSection() {
    return Selector<CVProvider, (String, String, bool)>(
      selector: (_, p) => (p.cvData.personalInfo.jobTitle, p.cvData.personalInfo.headerAlignment, p.cvData.personalInfo.showNameAsHeader),
      builder: (context, data, _) {
        final jobTitle = data.$1;
        final alignment = data.$2;
        final showName = data.$3;

        // Ensure controllers and state are in sync if they were changed externally
        if (_jobTitleCtrl.text != jobTitle) {
          _jobTitleCtrl.text = jobTitle;
        }
        _headerAlignment = alignment;
        _showNameAsHeader = showName;

        return ExpansionTile(
          leading: const Icon(Icons.badge),
          title: const Text('Header'),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _jobTitleCtrl,
              decoration: const InputDecoration(
                labelText: 'Job Title / Professional Title',
                hintText: 'e.g. Software Engineer',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Header Alignment', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                _headerAlignment == 'left',
                _headerAlignment == 'center',
                _headerAlignment == 'right',
              ],
              onPressed: (index) {
                setState(() {
                  if (index == 0) _headerAlignment = 'left';
                  if (index == 1) _headerAlignment = 'center';
                  if (index == 2) _headerAlignment = 'right';
                });
                _updatePersonalInfo();
              },
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
              children: const [
                Icon(Icons.format_align_left, size: 20),
                Icon(Icons.format_align_center, size: 20),
                Icon(Icons.format_align_right, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Use Name as Header Title', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Replaces "CURRICULUM VITAE" with your name', style: TextStyle(fontSize: 12)),
              value: _showNameAsHeader,
              onChanged: (val) {
                setState(() {
                  _showNameAsHeader = val ?? false;
                });
                _updatePersonalInfo();
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Divider(),
            const SizedBox(height: 8),

          ],
        );
      },
    );
  }



  Widget _buildSectionHeader(BuildContext context, String currentTitle, bool isVisible, bool startsOnNewPage, Function(String) onRename, VoidCallback onToggleVisibility, VoidCallback? onToggleNewPage, [VoidCallback? onRemove]) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentTitle,
                  style: TextStyle(color: isVisible ? null : Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (startsOnNewPage) ...[
                const SizedBox(width: 8),
                const Icon(Icons.insert_page_break_outlined, size: 16, color: Colors.blue),
              ],
              if (!isVisible) ...[
                const SizedBox(width: 8),
                const Icon(Icons.visibility_off, size: 16, color: Colors.grey),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            if (val == 'rename') {
              _showRenameDialog(context, currentTitle, onRename);
            } else if (val == 'toggle_visibility') {
              onToggleVisibility();
            } else if (val == 'toggle_new_page' && onToggleNewPage != null) {
              onToggleNewPage();
            } else if (val == 'remove' && onRemove != null) {
              onRemove();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Rename section'),
                ],
              ),
            ),
            if (onToggleNewPage != null)
              PopupMenuItem(
                value: 'toggle_new_page',
                child: Row(
                  children: [
                    Icon(
                      startsOnNewPage ? Icons.vertical_align_bottom : Icons.insert_page_break_outlined, 
                      size: 20, 
                      color: startsOnNewPage ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      startsOnNewPage ? 'Keep on same page' : 'Start on new page', 
                      style: TextStyle(color: startsOnNewPage ? Colors.blue : null),
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'toggle_visibility',
              child: Row(
                children: [
                  Icon(isVisible ? Icons.visibility_off : Icons.visibility, size: 20, color: isVisible ? Colors.red : Colors.green),
                  const SizedBox(width: 8),
                  Text(isVisible ? 'Hide from CV' : 'Show on CV', style: TextStyle(color: isVisible ? Colors.red : Colors.green)),
                ],
              ),
            ),
            if (onRemove != null)
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete section', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, String currentTitle, Function(String) onRename) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename section'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Section Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onRename(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection({Key? key}) {
    return Selector<CVProvider, SectionTitles>(
      key: key,
      selector: (_, p) => p.cvData.sectionTitles,
      builder: (context, titles, _) {
        final provider = context.read<CVProvider>();
        
        return ExpansionTile(
          leading: const Icon(Icons.person),
          title: _buildSectionHeader(context, titles.personalInfo, titles.showPersonalInfo, false, (val) {
            provider.updateSectionTitles(titles.copyWith(personalInfo: val));
          }, () {
            provider.updateSectionTitles(titles.copyWith(showPersonalInfo: !titles.showPersonalInfo));
          }, null),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            ..._fieldControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final pair = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pair.titleCtrl,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blueGrey,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (!pair.isCompulsory)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 18),
                            onPressed: () => _removeFieldController(index),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    TextFormField(
                      controller: pair.valueCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Value',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => _addFieldController(),
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Field'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLivePreview() {
    return Consumer<CVProvider>(
      builder: (context, provider, _) {
        return DebouncedPdfPreview(data: provider.cvData);
      },
    );
  }

  void _showMobilePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: _buildLivePreview(),
      ),
    );
  }
  Widget _buildAppBarTitle(BuildContext context) {
    final provider = context.watch<CVProvider>();

    if (Responsive.isMobile(context)) {
      return InkWell(
        onTap: () => _showFileNameDialog(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.cvData.pdfFileName.isEmpty ? 'Untitled CV' : provider.cvData.pdfFileName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 14, color: Colors.white70),
          ],
        ),
      );
    }

    return Row(
      children: [
        const Icon(Icons.description_outlined, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _pdfFileNameCtrl,
            cursorColor: Colors.white,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              hintText: 'Untitled CV',
              hintStyle: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  void _showFileNameDialog(BuildContext context) {
    final provider = context.read<CVProvider>();
    final controller = TextEditingController(text: provider.cvData.pdfFileName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename CV'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File Name',
            hintText: 'e.g. My_Awesome_CV',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.updatePdfFileName(controller.text.trim());
              _pdfFileNameCtrl.text = controller.text.trim();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
