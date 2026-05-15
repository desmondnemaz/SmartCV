# SmartCV Builder Codebase Walkthrough

This guide explains how the SmartCV Builder application is structured and how the different components interact. Use this as a map if you need to make manual code corrections.

## 1. Project Architecture (Clean Architecture Lite)
The project follows a feature-based structure to keep things organized:
- **`lib/core/`**: Shared models, services, and utilities.
- **`lib/features/`**: Divided into functional areas (Dashboard, Editor).
- **`lib/main.dart`**: Entry point where the app is initialized and the Provider is set up.

---

## 2. Data Models (`lib/core/models/`)
These files define what a "CV" actually is.
- **`cv_data.dart`**: The "Heart" of the app. It contains all the fields (Personal info, Education, Experience, etc.) and the `sectionOrder` list which controls the order of appearance.
- **Key Tip**: If you want to add a new type of field to a CV, start here.

---

## 3. Persistence & Logic (`lib/core/services/`)
- **`persistence_service.dart`**: Handles saving and loading CVs from the local database (Hive). It converts the `CVData` object to JSON and back.
- **`pdf_service.dart`**: Contains the logic for generating the actual PDF file using the `pdf` and `printing` packages.

---

## 4. State Management (`lib/features/editor/presentation/providers/`)
We use the **Provider** package for state management.
- **`cv_provider.dart`**: The "Brain" of the editor. 
    - It holds the current `CVData` being edited.
    - It triggers **auto-save** whenever a change is made.
    - It manages the list of all saved CVs (`_savedCVs`).
- **Key Tip**: If you need to change how data is updated or saved, this is the file to edit.

---

## 5. UI & Screens
### Dashboard (`lib/features/dashboard/presentation/screens/`)
- **`dashboard_screen.dart`**: The home screen. It displays the "Recent CVs" and handles creating new documents or deleting old ones.

### Editor (`lib/features/editor/presentation/screens/`)
- **`editor_screen.dart`**: The most complex file.
    - **Form Section**: Left side (on Desktop) where the user types.
    - **Preview Section**: Right side (on Desktop) or Bottom Sheet (on Mobile) showing the live PDF.
    - **`_buildSectionPicker`**: The Chips logic you just added.
- **`preview_section.dart`**: Handles the live update of the PDF preview and the "Download" button.

---

## 6. How Data Flows (A Keystroke's Journey)
1. User types in a `TextField` in `editor_screen.dart`.
2. A listener calls a method in `cv_provider.dart` (e.g., `updatePersonalInfo`).
3. `CVProvider` updates the `CVData` object and calls `_notifyAndSave()`.
4. `_notifyAndSave()` tells the `PersistenceService` to save to Hive.
5. `_notifyAndSave()` also calls `notifyListeners()`.
6. `preview_section.dart` hears the notification and triggers a refresh of the PDF preview.

---

## 7. Quick Reference: "Where do I touch?"
| To Change... | File to Edit |
| :--- | :--- |
| The design of the PDF | `lib/core/services/pdf_service.dart` |
| The color/font of the UI | `lib/main.dart` (ThemeData) |
| Adding a new section type | `lib/core/models/cv_data.dart` and `lib/features/editor/presentation/screens/editor_screen.dart` |
| The wording on the Dashboard | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| Persistence (Hive) settings | `lib/core/services/persistence_service.dart` |

---

> [!TIP]
> **Manual Corrections**: If you are editing the UI, search for the `Widget` build methods in `editor_screen.dart`. Most of them start with `_build...` (e.g., `_buildExperienceSection`).
