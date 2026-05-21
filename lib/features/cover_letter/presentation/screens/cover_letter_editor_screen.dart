import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcv_builder/core/utils/responsive.dart';
import 'package:smartcv_builder/features/cover_letter/presentation/providers/cover_letter_provider.dart';
import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/features/cover_letter/presentation/components/cover_letter_preview_section.dart';
import 'package:smartcv_builder/features/editor/presentation/components/rich_text_editor_field.dart';

class CoverLetterEditorScreen extends StatefulWidget {
  const CoverLetterEditorScreen({super.key});

  @override
  State<CoverLetterEditorScreen> createState() => _CoverLetterEditorScreenState();
}

class _CoverLetterEditorScreenState extends State<CoverLetterEditorScreen> {
  late TextEditingController _pdfFileNameCtrl;
  
  // Sender Controllers
  late TextEditingController _senderNameCtrl;
  late TextEditingController _senderJobTitleCtrl;
  late TextEditingController _senderEmailCtrl;
  late TextEditingController _senderPhoneCtrl;
  late TextEditingController _senderAddressCtrl;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final cl = context.watch<CoverLetterProvider>().coverLetterData;
      
      _pdfFileNameCtrl = TextEditingController(text: cl.pdfFileName);
      
      // Sender Details
      _senderNameCtrl = TextEditingController(text: cl.senderName);
      _senderJobTitleCtrl = TextEditingController(text: cl.senderJobTitle);
      _senderEmailCtrl = TextEditingController(text: cl.senderEmail);
      _senderPhoneCtrl = TextEditingController(text: cl.senderPhone);
      _senderAddressCtrl = TextEditingController(text: cl.senderAddress);

      // Set up listeners for saving state
      _pdfFileNameCtrl.addListener(() {
        context.read<CoverLetterProvider>().updatePdfFileName(_pdfFileNameCtrl.text);
      });

      _initSenderListeners();

      _isInit = false;
    }
  }

  void _initSenderListeners() {
    void onSenderChanged() {
      context.read<CoverLetterProvider>().updateSenderDetails(
            name: _senderNameCtrl.text,
            jobTitle: _senderJobTitleCtrl.text,
            email: _senderEmailCtrl.text,
            phone: _senderPhoneCtrl.text,
            address: _senderAddressCtrl.text,
          );
    }
    _senderNameCtrl.addListener(onSenderChanged);
    _senderJobTitleCtrl.addListener(onSenderChanged);
    _senderEmailCtrl.addListener(onSenderChanged);
    _senderPhoneCtrl.addListener(onSenderChanged);
    _senderAddressCtrl.addListener(onSenderChanged);
  }

  @override
  void dispose() {
    _pdfFileNameCtrl.dispose();
    _senderNameCtrl.dispose();
    _senderJobTitleCtrl.dispose();
    _senderEmailCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _senderAddressCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmLeaveEditor(BuildContext context) async {
    final clProv = context.read<CoverLetterProvider>();
    
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.mail_outline, size: 40, color: Colors.blueGrey),
        title: const Text(
          'Leave Editor?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Would you like to discard this cover letter or save it as a draft?',
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
            child: const Text('Save Draft'),
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
      await clProv.discardCurrentCoverLetter();
      return true;
    } else if (choice == 'draft') {
      await clProv.saveCurrentCoverLetter();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final clProv = context.watch<CoverLetterProvider>();
    final cl = clProv.coverLetterData;

    // Keep inputs synced if linked CV updates
    if (cl.linkedCvId != null) {
      _senderNameCtrl.text = cl.senderName;
      _senderJobTitleCtrl.text = cl.senderJobTitle;
      _senderEmailCtrl.text = cl.senderEmail;
      _senderPhoneCtrl.text = cl.senderPhone;
      _senderAddressCtrl.text = cl.senderAddress;
    }

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
          title: Text(cl.pdfFileName.isEmpty ? 'Cover Letter Editor' : cl.pdfFileName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
              onPressed: () {
                clProv.saveCurrentCoverLetter();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cover Letter saved successfully'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: _buildEditorForm(clProv),
            ),
            if (Responsive.isDesktop(context)) const VerticalDivider(width: 1),
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 3,
                child: DebouncedCoverLetterPreview(data: cl),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorForm(CoverLetterProvider clProv) {
    final cl = clProv.coverLetterData;
    final cvProv = context.watch<CVProvider>();
    final savedCVs = cvProv.savedCVs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Header Section
          _buildExpansionTile(
            title: 'Header',
            icon: Icons.badge,
            isSynced: cl.linkedCvId != null,
            children: [
              TextField(
                controller: _pdfFileNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: cl.linkedCvId,
                decoration: const InputDecoration(
                  labelText: 'Link with Resume',
                  helperText: 'Link to automatically sync layout colors, fonts, and sender info.',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None (Standalone)'),
                  ),
                  ...savedCVs.map((cv) => DropdownMenuItem<String>(
                        value: cv.id,
                        child: Text(cv.pdfFileName),
                      )),
                ],
                onChanged: (val) {
                  clProv.updateLinkedCvId(val, savedCVs);
                },
              ),
              const SizedBox(height: 12),
              if (cl.linkedCvId != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Header styling and professional title are synced with your linked resume. Unlink above to edit details separately.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              TextField(
                controller: _senderJobTitleCtrl,
                enabled: cl.linkedCvId == null,
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
                  cl.headerAlignment == 'left',
                  cl.headerAlignment == 'center',
                  cl.headerAlignment == 'right',
                ],
                onPressed: cl.linkedCvId == null
                    ? (index) {
                        String newAlign = 'left';
                        if (index == 1) newAlign = 'center';
                        if (index == 2) newAlign = 'right';
                        context.read<CoverLetterProvider>().updateStyling(headerAlignment: newAlign);
                      }
                    : null,
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
                subtitle: const Text('Replaces "COVER LETTER" with your name', style: TextStyle(fontSize: 12)),
                value: cl.showNameAsHeader,
                onChanged: cl.linkedCvId == null
                    ? (val) {
                        context.read<CoverLetterProvider>().updateStyling(showNameAsHeader: val ?? false);
                      }
                    : null,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: Theme.of(context).primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Personal Information Section
          _buildExpansionTile(
            title: 'Personal Information',
            icon: Icons.person,
            isSynced: cl.linkedCvId != null,
            children: [
              if (cl.linkedCvId != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Personal info is synced with your linked resume. Unlink in the Header section to edit details separately.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              TextField(
                controller: _senderNameCtrl,
                enabled: cl.linkedCvId == null,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senderEmailCtrl,
                enabled: cl.linkedCvId == null,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senderPhoneCtrl,
                enabled: cl.linkedCvId == null,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senderAddressCtrl,
                enabled: cl.linkedCvId == null,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Letter Body Section
          _buildExpansionTile(
            title: 'Letter Body',
            icon: Icons.edit_note,
            initiallyExpanded: true,
            children: [
              RichTextEditorField(
                initialValue: cl.body,
                placeholder: 'Write your professional cover letter here...',
                height: 450,
                onChanged: (bodyJson) {
                  clProv.updateBody(bodyJson);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isSynced = false,
    bool initiallyExpanded = false,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: Icon(icon, color: isSynced ? primaryColor : null),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSynced ? primaryColor : null,
            ),
          ),
          if (isSynced) ...[
            const SizedBox(width: 8),
            Icon(Icons.link, size: 16, color: primaryColor),
          ],
        ],
      ),
      childrenPadding: const EdgeInsets.all(16),
      expandedAlignment: Alignment.topLeft,
      children: children,
    );
  }

  void _showMobilePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cl = context.watch<CoverLetterProvider>().coverLetterData;
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text('Live PDF Preview'),
                leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
              ),
              Expanded(
                child: DebouncedCoverLetterPreview(data: cl),
              ),
            ],
          ),
        );
      },
    );
  }
}
