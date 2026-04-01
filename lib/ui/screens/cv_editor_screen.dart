import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../providers/cv_provider.dart';
import '../../services/pdf_service.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cv_data.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'dart:convert';
import 'dart:async';

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

class _CustomSectionControllers {
  final fq.QuillController quillController;
  final ScrollController scrollController;
  final FocusNode focusNode;

  _CustomSectionControllers({
    required this.quillController,
    required this.scrollController,
    required this.focusNode,
  });

  void dispose() {
    quillController.dispose();
    scrollController.dispose();
    focusNode.dispose();
  }
}

class _CVEditorScreenState extends State<CVEditorScreen> {
  late TextEditingController _jobTitleCtrl;
  late fq.QuillController _summaryQuillCtrl;
  final ScrollController _summaryScrollCtrl = ScrollController();
  final FocusNode _summaryFocusNode = FocusNode();
  String _headerAlignment = 'left';
  bool _showNameAsHeader = false;
  final List<_FieldControllerPair> _fieldControllers = [];
  // Map to store Quill-related controllers for custom sections to persist state and dispose properly
  final Map<String, _CustomSectionControllers> _customControllers = {};

  @override
  void initState() {
    super.initState();
    final info = context.read<CVProvider>().cvData.personalInfo;
    
    // Initialize Summary Quill Controller
    try {
      if (info.profileSummary.isEmpty) {
        _summaryQuillCtrl = fq.QuillController.basic();
      } else {
        _summaryQuillCtrl = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(info.profileSummary)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (e) {
      _summaryQuillCtrl = fq.QuillController.basic();
      if (info.profileSummary.isNotEmpty) {
        _summaryQuillCtrl.document.insert(0, info.profileSummary);
      }
    }
    _summaryQuillCtrl.addListener(_updatePersonalInfo);
    
    _jobTitleCtrl = TextEditingController(text: info.jobTitle);
    _jobTitleCtrl.addListener(_updatePersonalInfo);
    _headerAlignment = info.headerAlignment;
    _showNameAsHeader = info.showNameAsHeader;

    for (var field in info.fields) {
      _addFieldController(field.title, field.value, field.isCompulsory);
    }
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

    context.read<CVProvider>().updatePersonalInfo(PersonalInfo(
      jobTitle: _jobTitleCtrl.text,
      headerAlignment: _headerAlignment,
      fields: fields,
      profileSummary: jsonEncode(_summaryQuillCtrl.document.toDelta().toJson()),
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
    _summaryQuillCtrl.dispose();
    _summaryScrollCtrl.dispose();
    _summaryFocusNode.dispose();
    _jobTitleCtrl.dispose();
    for (var pair in _fieldControllers) {
      pair.dispose();
    }
    for (var controllers in _customControllers.values) {
      controllers.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCV Editor'),
        actions: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _showMobilePreview(context),
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
    );
  }

  Widget _buildEditorForm() {
    return Consumer<CVProvider>(
      builder: (context, provider, child) {
        final order = provider.cvData.sectionOrder;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildHeaderSection(),
            ),
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  provider.reorderSections(oldIndex, newIndex);
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
                  const SizedBox(key: ValueKey('footerSpacer'), height: 32),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                  provider.addCustomSection(
                    CustomSection(id: id),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Section'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionByKey(String key) {
    if (key.startsWith('custom_')) {
      return _buildCustomSection(key);
    }
    switch (key) {
      case 'personalInfo': return _buildPersonalInfoSection();
      case 'professionalSummary': return _buildProfessionalSummarySection();
      case 'experience': return _buildExperienceSection();
      case 'internships': return _buildInternshipSection();
      case 'education': return _buildEducationSection();
      case 'skills': return _buildSkillsSection();
      case 'certifications': return _buildCertificationSection();
      case 'references': return _buildReferencesSection();
      default: return const SizedBox.shrink();
    }
  }


  Widget _buildHeaderSection() {
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
          title: const Text('Use Full Name as Header Title', style: TextStyle(fontSize: 14)),
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
      ],
    );
  }



  Widget _buildSectionHeader(BuildContext context, String currentTitle, bool isVisible, Function(String) onRename, VoidCallback onToggleVisibility) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                currentTitle,
                style: TextStyle(color: isVisible ? null : Colors.grey),
              ),
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
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        return ExpansionTile(
          leading: const Icon(Icons.person),
          title: _buildSectionHeader(context, titles.personalInfo, titles.showPersonalInfo, (val) {
            titles.personalInfo = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showPersonalInfo = !titles.showPersonalInfo;
            provider.updateSectionTitles(titles);
          }),
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

  Widget _buildProfessionalSummarySection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        return ExpansionTile(
          leading: const Icon(Icons.description),
          title: _buildSectionHeader(context, titles.professionalSummary, titles.showProfessionalSummary, (val) {
            titles.professionalSummary = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showProfessionalSummary = !titles.showProfessionalSummary;
            provider.updateSectionTitles(titles);
          }),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      // Toolbar at the top for better accessibility in a smaller section
                      fq.QuillSimpleToolbar(
                        controller: _summaryQuillCtrl,
                        config: const fq.QuillSimpleToolbarConfig(
                          showInlineCode: false,
                          showCodeBlock: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showClearFormat: false,
                          showSearchButton: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showBoldButton: true,
                          showItalicButton: true,
                          showUnderLineButton: false,
                          showStrikeThrough: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showAlignmentButtons: true,
                          showLeftAlignment: false,
                          showCenterAlignment: false,
                          showRightAlignment: false,
                          showJustifyAlignment: true,
                          showListNumbers: false,
                          showListBullets: false,
                          showListCheck: false,
                          showQuote: false,
                          showIndent: false,
                          showLink: false,
                          showUndo: true,
                          showRedo: true,
                          multiRowsDisplay: false,
                        ),
                      ),
                      const Divider(height: 1),
                      // Editor Area
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 150,
                          child: fq.QuillEditor(
                            controller: _summaryQuillCtrl,
                            scrollController: _summaryScrollCtrl,
                            focusNode: _summaryFocusNode,
                            config: const fq.QuillEditorConfig(
                              placeholder: 'Write your professional summary...',
                              expands: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomSection(String id) {
    return Consumer<CVProvider>(
      key: ValueKey(id),
      builder: (context, provider, _) {
        final customSections = provider.cvData.customSections;
        final sectionIndex = customSections.indexWhere((s) => s.id == id);
        if (sectionIndex == -1) return const SizedBox.shrink();
        
        final section = customSections[sectionIndex];
        
        // --- Manage Quill Controller ---
        if (!_customControllers.containsKey(id)) {
          fq.QuillController quillController;
          try {
            if (section.description.isEmpty) {
              quillController = fq.QuillController.basic();
            } else {
              // Try to load as JSON (Quill Delta)
              final doc = fq.Document.fromJson(jsonDecode(section.description));
              quillController = fq.QuillController(
                document: doc,
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
          } catch (e) {
            // Fallback for plain text
            quillController = fq.QuillController.basic();
            if (section.description.isNotEmpty) {
              quillController.document.insert(0, section.description);
            }
          }

          // Add listener to save changes to provider
          quillController.addListener(() {
            final json = jsonEncode(quillController.document.toDelta().toJson());
            // Only update if changes actually happen to avoid infinite loops or heavy notifying
            if (section.description != json) {
              section.description = json;
              provider.updateCustomSection(id, section);
            }
          });
          
          _customControllers[id] = _CustomSectionControllers(
            quillController: quillController,
            scrollController: ScrollController(),
            focusNode: FocusNode(),
          );
        }

        final controllers = _customControllers[id]!;
        final controller = controllers.quillController;

        return ExpansionTile(
          leading: const Icon(Icons.dashboard_customize),
          title: _buildSectionHeader(context, section.title, section.isVisible, (val) {
            section.title = val;
            provider.updateSectionTitles(provider.cvData.sectionTitles); // Trigger update
            provider.updateCustomSection(id, section);
          }, () {
            section.isVisible = !section.isVisible;
            provider.updateCustomSection(id, section);
          }),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Dispose controller when removing section
                    _customControllers.remove(id)?.dispose();
                    provider.removeCustomSection(id);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Section', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            // --- Rich Text Editor UI ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      // Editor Area
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 250,
                          child: fq.QuillEditor(
                            controller: controller,
                            scrollController: controllers.scrollController,
                            focusNode: controllers.focusNode,
                            config: const fq.QuillEditorConfig(
                              placeholder: 'Describe this section...',
                              expands: true,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      // Toolbar at the bottom with specific options as requested
                      fq.QuillSimpleToolbar(
                        controller: controller,
                        config: const fq.QuillSimpleToolbarConfig(

                          // Hide the buttons
                          showInlineCode: false,
                          showCodeBlock: false,    // Hides <>
                          showSubscript: false,    // Hides X₂
                          showSuperscript: false,  // Hides X²
                          showClearFormat: false,   // Hides the T with the slash
                          showSearchButton: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showBoldButton: true,
                          showItalicButton: true,
                          showUnderLineButton: true,
                          showStrikeThrough: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showAlignmentButtons: true,
                          showLeftAlignment: true,
                          showCenterAlignment: true,
                          showRightAlignment: true,
                          showJustifyAlignment: true,
                          showListNumbers: true,
                          showListBullets: true,
                          showListCheck: false,
                          showQuote: false,
                          showIndent: false,
                          showLink: false,
                          showUndo: true,
                          showRedo: true,
                          multiRowsDisplay: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildExperienceSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.experience;
        return ExpansionTile(
          leading: const Icon(Icons.work),
          title: _buildSectionHeader(context, titles.experience, titles.showExperience, (val) {
            titles.experience = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showExperience = !titles.showExperience;
            provider.updateSectionTitles(titles);
          }),
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
                                onPressed: () => provider.removeExperience(index),
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
                          TextFormField(
                            initialValue: exp.description,
                            decoration: const InputDecoration(labelText: 'Description', isDense: true),
                            maxLines: 2,
                            onChanged: (val) {
                              exp.description = val;
                              provider.updateExperience(index, exp);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addExperience(Experience()),
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

  Widget _buildInternshipSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.internships;
        return ExpansionTile(
          leading: const Icon(Icons.history_edu),
          title: _buildSectionHeader(context, titles.internships, titles.showInternships, (val) {
            titles.internships = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showInternships = !titles.showInternships;
            provider.updateSectionTitles(titles);
          }),
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
                                onPressed: () => provider.removeInternship(index),
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
                          TextFormField(
                            initialValue: internship.description,
                            decoration: const InputDecoration(labelText: 'Description', isDense: true),
                            maxLines: 2,
                            onChanged: (val) {
                              internship.description = val;
                              provider.updateInternship(index, internship);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addInternship(Internship()),
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

  Widget _buildReferencesSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.references;
        return ExpansionTile(
          leading: const Icon(Icons.people),
          title: _buildSectionHeader(context, titles.references, titles.showReferences, (val) {
            titles.references = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showReferences = !titles.showReferences;
            provider.updateSectionTitles(titles);
          }),
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
                              const Text('Reference', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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
                            onChanged: (val) {
                              reference.name = val;
                              provider.updateReference(index, reference);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: reference.position,
                            decoration: const InputDecoration(labelText: 'Position', isDense: true),
                            onChanged: (val) {
                              reference.position = val;
                              provider.updateReference(index, reference);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: reference.company,
                            decoration: const InputDecoration(labelText: 'Company/Organization', isDense: true),
                            onChanged: (val) {
                              reference.company = val;
                              provider.updateReference(index, reference);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: reference.email,
                                  decoration: const InputDecoration(labelText: 'Email', isDense: true),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (val) {
                                    reference.email = val;
                                    provider.updateReference(index, reference);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: reference.phone,
                                  decoration: const InputDecoration(labelText: 'Phone', isDense: true),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (val) {
                                    reference.phone = val;
                                    provider.updateReference(index, reference);
                                  },
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

  Widget _buildEducationSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.education;
        return ExpansionTile(
          leading: const Icon(Icons.school),
          title: _buildSectionHeader(context, titles.education, titles.showEducation, (val) {
            titles.education = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showEducation = !titles.showEducation;
            provider.updateSectionTitles(titles);
          }),
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
                                onPressed: () => provider.removeEducation(index),
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
                          TextFormField(
                            initialValue: ed.description,
                            decoration: const InputDecoration(labelText: 'Description', isDense: true),
                            maxLines: 2,
                            onChanged: (val) {
                              ed.description = val;
                              provider.updateEducation(index, ed);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addEducation(Education()),
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

  Widget _buildSkillsSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.skills;
        return ExpansionTile(
          leading: const Icon(Icons.star),
          title: _buildSectionHeader(context, titles.skills, titles.showSkills, (val) {
            titles.skills = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showSkills = !titles.showSkills;
            provider.updateSectionTitles(titles);
          }),
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

  Widget _buildCertificationSection({Key? key}) {
    return Consumer<CVProvider>(
      key: key,
      builder: (context, provider, _) {
        final titles = provider.cvData.sectionTitles;
        final list = provider.cvData.certifications;
        return ExpansionTile(
          leading: const Icon(Icons.verified),
          title: _buildSectionHeader(context, titles.certifications, titles.showCertifications, (val) {
            titles.certifications = val;
            provider.updateSectionTitles(titles);
          }, () {
            titles.showCertifications = !titles.showCertifications;
            provider.updateSectionTitles(titles);
          }),
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
                                onPressed: () => provider.removeCertification(index),
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
                          TextFormField(
                            initialValue: cert.description,
                            decoration: const InputDecoration(labelText: 'Description (Optional)', isDense: true),
                            maxLines: 2,
                            onChanged: (val) {
                              cert.description = val;
                              provider.updateCertification(index, cert);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.addCertification(Certification()),
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

}

class DebouncedPdfPreview extends StatefulWidget {
  final CVData data;
  const DebouncedPdfPreview({super.key, required this.data});

  @override
  State<DebouncedPdfPreview> createState() => _DebouncedPdfPreviewState();
}

class _DebouncedPdfPreviewState extends State<DebouncedPdfPreview> {
  Timer? _debounceTimer;
  late CVData _previewData;

  @override
  void initState() {
    super.initState();
    _previewData = widget.data;
  }

  @override
  void didUpdateWidget(DebouncedPdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Use a shorter debounce of 400ms for more responsive feel.
    // Instead of showing a spinner, we keep the old data until the new is ready.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _previewData = widget.data;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              PopupMenuButton<double>(
                icon: const Icon(Icons.format_line_spacing, size: 18, color: Colors.blueGrey),
                tooltip: 'Line Height',
                onSelected: (val) {
                  context.read<CVProvider>().updateLineHeight(val);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('LINE HEIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  _buildLineHeightItem(1.0, '1', widget.data.lineHeight),
                  _buildLineHeightItem(1.15, '1.15', widget.data.lineHeight),
                  _buildLineHeightItem(1.25, '1.25', widget.data.lineHeight),
                  _buildLineHeightItem(1.5, '1.5', widget.data.lineHeight),
                  _buildLineHeightItem(2.0, '2', widget.data.lineHeight),
                ],
              ),
              const VerticalDivider(width: 20, indent: 8, endIndent: 8),
              const Icon(Icons.format_size, size: 18, color: Colors.blueGrey),
              const SizedBox(width: 12),
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: widget.data.baseFontSize.clamp(10, 14),
                    min: 10,
                    max: 14,
                    divisions: 4,
                    label: widget.data.baseFontSize.round().toString(),
                    onChanged: (val) {
                      context.read<CVProvider>().updateBaseFontSize(val);
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.data.baseFontSize.round().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.fullscreen, size: 20, color: Colors.blueGrey),
                tooltip: 'Full Screen',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenPreview(data: widget.data),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PdfPreview(
            build: (format) => PDFService.generateCV(_previewData),
            allowSharing: true,
            allowPrinting: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<double> _buildLineHeightItem(double value, String label, double current) {
    return PopupMenuItem<double>(
      value: value,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: current == value ? const Icon(Icons.check, size: 16) : null,
          ),
          Text(label),
        ],
      ),
    );
  }
}

class FullScreenPreview extends StatelessWidget {
  final CVData data;

  const FullScreenPreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade800,
        elevation: 0.5,
      ),
      body: PdfPreview(
        build: (format) => PDFService.generateCV(data),
        allowSharing: true,
        allowPrinting: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}