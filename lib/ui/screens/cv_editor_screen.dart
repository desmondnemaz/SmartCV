import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../providers/cv_provider.dart';
import '../../services/pdf_service.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cv_data.dart';

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
  late TextEditingController _summaryCtrl;
  late TextEditingController _jobTitleCtrl;
  String _headerAlignment = 'left';
  final List<_FieldControllerPair> _fieldControllers = [];

  @override
  void initState() {
    super.initState();
    final info = context.read<CVProvider>().cvData.personalInfo;
    _summaryCtrl = TextEditingController(text: info.profileSummary);
    _summaryCtrl.addListener(_updatePersonalInfo);
    
    _jobTitleCtrl = TextEditingController(text: info.jobTitle);
    _jobTitleCtrl.addListener(_updatePersonalInfo);
    _headerAlignment = info.headerAlignment;

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
      profileSummary: _summaryCtrl.text,
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
    _summaryCtrl.dispose();
    _jobTitleCtrl.dispose();
    for (var pair in _fieldControllers) {
      pair.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Editor'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderSection(),
        _buildPersonalInfoSection(),
        _buildProfessionalSummarySection(),
        _buildExperienceSection(),
        _buildEducationSection(),
        _buildSkillsSection(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return ExpansionTile(
      leading: const Icon(Icons.badge),
      title: const Text('Header'),
      initiallyExpanded: true,
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
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return ExpansionTile(
      leading: const Icon(Icons.person),
      title: const Text('Personal Information'),
      initiallyExpanded: true,
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
  }

  Widget _buildProfessionalSummarySection() {
    return ExpansionTile(
      leading: const Icon(Icons.description),
      title: const Text('Professional Summary'),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _summaryCtrl,
          decoration: const InputDecoration(labelText: 'Summary'),
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return ExpansionTile(
      leading: const Icon(Icons.work),
      title: const Text('Experience'),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        Consumer<CVProvider>(
          builder: (context, provider, _) {
            final list = provider.cvData.experience;
            return Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exp = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(exp.position),
                      subtitle: Text(exp.company),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.removeExperience(index),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddExperienceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return ExpansionTile(
      leading: const Icon(Icons.school),
      title: const Text('Education'),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        Consumer<CVProvider>(
          builder: (context, provider, _) {
            final list = provider.cvData.education;
            return Column(
              children: [
                ...list.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ed = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(ed.institution),
                      subtitle: Text(ed.degree),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.removeEducation(index),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddEducationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return ExpansionTile(
      leading: const Icon(Icons.star),
      title: const Text('Skills'),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        Consumer<CVProvider>(
          builder: (context, provider, _) {
            final list = provider.cvData.skills;
            return Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: list.asMap().entries.map((entry) {
                    final index = entry.key;
                    final skill = entry.value;
                    return Chip(
                      label: Text(skill.name),
                      onDeleted: () => provider.removeSkill(index),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddSkillDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Skill'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    return Consumer<CVProvider>(
      builder: (context, provider, _) {
        return PdfPreview(
          build: (format) => PDFService.generateCV(provider.cvData),
          allowSharing: true,
          allowPrinting: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
        );
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

  void _showAddExperienceDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final companyCtrl = TextEditingController();
    final positionCtrl = TextEditingController();
    final startDateCtrl = TextEditingController();
    final endDateCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Experience'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: positionCtrl, decoration: const InputDecoration(labelText: 'Job Title')),
                TextFormField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company')),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: startDateCtrl, decoration: const InputDecoration(labelText: 'Start'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: endDateCtrl, decoration: const InputDecoration(labelText: 'End'))),
                  ],
                ),
                TextFormField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<CVProvider>().addExperience(Experience(
                  company: companyCtrl.text,
                  position: positionCtrl.text,
                  startDate: startDateCtrl.text,
                  endDate: endDateCtrl.text,
                  description: descriptionCtrl.text,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEducationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final institutionCtrl = TextEditingController();
    final degreeCtrl = TextEditingController();
    final startDateCtrl = TextEditingController();
    final endDateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: institutionCtrl, decoration: const InputDecoration(labelText: 'Institution')),
                TextFormField(controller: degreeCtrl, decoration: const InputDecoration(labelText: 'Degree')),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: startDateCtrl, decoration: const InputDecoration(labelText: 'Start'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: endDateCtrl, decoration: const InputDecoration(labelText: 'End'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<CVProvider>().addEducation(Education(
                  institution: institutionCtrl.text,
                  degree: degreeCtrl.text,
                  startDate: startDateCtrl.text,
                  endDate: endDateCtrl.text,
                  description: '',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Skill Name'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<CVProvider>().addSkill(Skill(name: nameCtrl.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
