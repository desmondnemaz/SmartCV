import 'package:flutter/material.dart';

/// A reusable header widget for ExpansionTiles in the CV Editor.
/// It displays the section title and provides a popup menu for actions 
/// such as renaming the section, toggling its visibility on the CV, and deleting it.
class ExpandableSectionTitle extends StatelessWidget {
  /// The current title of the section (e.g., "Experience").
  final String sectionTitle;
  
  /// Whether the section is currently set to be visible on the generated CV.
  final bool isVisibleOnCv;
  
  /// Callback triggered when the user renames the section.
  final Function(String newTitle) onTitleRenamed;
  
  /// Callback triggered when the visibility toggle is pressed.
  final VoidCallback onVisibilityToggled;
  
  /// Optional callback triggered when the delete action is pressed.
  /// If null, the delete option is hidden.
  final VoidCallback? onSectionRemoved;

  const ExpandableSectionTitle({
    super.key,
    required this.sectionTitle,
    required this.isVisibleOnCv,
    required this.onTitleRenamed,
    required this.onVisibilityToggled,
    this.onSectionRemoved,
  });

  void _promptRenameDialog(BuildContext context) {
    final titleController = TextEditingController(text: sectionTitle);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename section'),
        content: TextFormField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Section Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                onTitleRenamed(newTitle);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sectionTitle,
                  style: TextStyle(color: isVisibleOnCv ? null : Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isVisibleOnCv) ...[
                const SizedBox(width: 8),
                const Icon(Icons.visibility_off, size: 16, color: Colors.grey),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String selectedAction) {
            if (selectedAction == 'rename') {
              _promptRenameDialog(context);
            } else if (selectedAction == 'toggle_visibility') {
              onVisibilityToggled();
            } else if (selectedAction == 'remove' && onSectionRemoved != null) {
              onSectionRemoved!();
            }
          },
          itemBuilder: (popupContext) => [
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
                  Icon(
                    isVisibleOnCv ? Icons.visibility_off : Icons.visibility, 
                    size: 20, 
                    color: isVisibleOnCv ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isVisibleOnCv ? 'Hide from CV' : 'Show on CV', 
                    style: TextStyle(color: isVisibleOnCv ? Colors.red : Colors.green),
                  ),
                ],
              ),
            ),
            if (onSectionRemoved != null)
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
}
