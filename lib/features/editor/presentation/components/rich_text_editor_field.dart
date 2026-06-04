import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'dart:convert';

/// A self-contained rich text editor widget using Flutter Quill.
/// It manages its own [QuillController] and [FocusNode] to prevent 
/// state loss or memory leaks when the UI re-renders or sections are reordered.
class RichTextEditorField extends StatefulWidget {
  /// The initial JSON string representing the Quill delta document.
  final String initialValue;
  
  /// Callback triggered whenever the text content changes.
  final Function(String) onChanged;
  
  /// The height of the editor area.
  final double height;
  
  /// Placeholder text shown when the editor is empty.
  final String placeholder;

  const RichTextEditorField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.height = 150,
    this.placeholder = 'Describe...',
  });

  @override
  State<RichTextEditorField> createState() => _RichTextEditorFieldState();
}

class _RichTextEditorFieldState extends State<RichTextEditorField> {
  late fq.QuillController _quillController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      if (widget.initialValue.isEmpty) {
        _quillController = fq.QuillController.basic();
      } else if (widget.initialValue.startsWith('[') || widget.initialValue.startsWith('{')) {
        _quillController = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(widget.initialValue)),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        _quillController = fq.QuillController.basic();
        _quillController.document.insert(0, widget.initialValue);
      }
    } catch (e) {
      _quillController = fq.QuillController.basic();
      if (widget.initialValue.isNotEmpty) {
        _quillController.document.insert(0, widget.initialValue);
      }
    }

    _quillController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    final jsonString = jsonEncode(_quillController.document.toDelta().toJson());
    widget.onChanged(jsonString);
  }

  @override
  void dispose() {
    _quillController.removeListener(_onContentChanged);
    _quillController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              fq.QuillSimpleToolbar(
                controller: _quillController,
                config: fq.QuillSimpleToolbarConfig(
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
                  buttonOptions: fq.QuillSimpleToolbarButtonOptions(
                    base: fq.QuillToolbarBaseButtonOptions(
                      iconTheme: fq.QuillIconTheme(
                        // Selected button: blue icon on a light grey background
                        iconButtonSelectedData: fq.IconButtonData(
                          color: Colors.blue,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.black12,
                            ),
                          ),
                        ),
                        // Unselected button: dark grey icon, transparent bg
                        iconButtonUnselectedData: fq.IconButtonData(
                          color: Colors.grey.shade700,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: widget.height,
                  child: fq.QuillEditor(
                    controller: _quillController,
                    scrollController: _scrollController,
                    focusNode: _focusNode,
                    config: fq.QuillEditorConfig(
                      placeholder: widget.placeholder,
                      expands: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
