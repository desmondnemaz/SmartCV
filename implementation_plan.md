# Implementation Plan - Unify Editor Leave/Discard Dialogs (Compact & Small-Screen Friendly)

This plan ensures that both the CV Editor and Cover Letter Editor use a unified leave/discard confirmation dialog with compact, small-screen friendly buttons.

## Proposed Changes

### 1. CV Editor
#### [MODIFY] [editor_screen.dart](file:///d:/flutterApps/smartcv_builder/lib/features/editor/presentation/screens/editor_screen.dart)

- **Unify `_confirmLeaveEditor` Dialog**:
  - Replace the split dialog logic with a single unified 3-button dialog.
  - Apply compact styling to the buttons (reduced horizontal/vertical padding) to prevent overflow on narrow screens.
  - Present:
    - **Icon**: `Icons.description_outlined`
    - **Title**: "Leave Editor?"
    - **Content**: "Would you like to discard this CV or save it as a draft?"
    - **Actions**:
      - `TextButton` (compact): **Keep Editing**
      - `OutlinedButton` (compact, 8px rounded): **Save Draft**
      - `ElevatedButton` (compact, red, 8px rounded): **Discard**

### 2. Cover Letter Editor
#### [MODIFY] [cover_letter_editor_screen.dart](file:///d:/flutterApps/smartcv_builder/lib/features/cover_letter/presentation/screens/cover_letter_editor_screen.dart)

- **Adjust `_confirmLeaveEditor` Button Sizes**:
  - Reduce button padding in the dialog actions from `horizontal: 16, vertical: 12` to `horizontal: 12, vertical: 8` (or similar compact sizes).
  - This ensures symmetric alignment with the CV Editor dialog.

---

## Verification Plan

### Automated Tests
- Run `analyze_files` or `flutter analyze` to verify the project has no compile or lint issues.

### Manual Verification
- Manually trigger the exit dialog on small/simulated screens.
- Verify that the layout remains compact, readable, and does not overflow.
