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

## 5. Reusable Editor Components (`lib/features/editor/presentation/components/`)
These are shared building blocks used by section widgets:
- **`rich_text_editor_field.dart`**: A self-contained Quill rich text editor widget. It owns its own `QuillController`, `ScrollController`, and `FocusNode`. Use this wherever you need a rich text input — never manage Quill controllers manually in screen-level code.
- **`expandable_section_title.dart`**: A reusable header for `ExpansionTile` widgets. It provides the section title, visibility icon, and a popup menu with **Rename**, **Hide/Show**, and **Delete** actions.
- **`preview_section.dart`**: Handles the live update of the PDF preview and the "Download" button.

---

## 6. UI & Screens

### Dashboard (`lib/features/dashboard/presentation/screens/`)
- **`dashboard_screen.dart`**: The home screen. Displays "Recent CVs", handles creating new documents or deleting old ones.

### Editor Screen (`lib/features/editor/presentation/screens/`)
- **`editor_screen.dart`**: The layout orchestrator — **not** a section builder.
    - **Left panel** (desktop): scrollable list of section widgets, driven by `sectionOrder`.
    - **Right panel** (desktop) / **Bottom Sheet** (mobile): live PDF preview.
    - **`_buildSectionByKey(key)`**: The router that maps a section key to its widget.
    - **`_buildSectionPicker`**: The chip row at the bottom for adding new sections.
    - **`_buildPersonalInfoSection`** and **`_buildHeaderSection`**: The only two inline builders remaining — they use local `TextEditingController` state that belongs in this screen.
    - **`_confirmLeaveEditor`**: Guard dialog that auto-saves or discards an empty CV on back navigation.

### Section Widgets (`lib/features/editor/presentation/screens/sections/`)
Each CV section is its own **self-contained `StatelessWidget`** that reads from `CVProvider` via `Selector`. To edit a section's UI, go directly to its file:

| File | Widget | Section Key |
| :--- | :--- | :--- |
| `professional_summary_section.dart` | `ProfessionalSummarySection` | `professionalSummary` |
| `experience_section.dart` | `ExperienceSection` | `experience` |
| `internships_section.dart` | `InternshipsSection` | `internships` |
| `education_section.dart` | `EducationSection` | `education` |
| `skills_section.dart` | `SkillsSection` | `skills` |
| `projects_section.dart` | `ProjectsSection` | `projects` |
| `certifications_section.dart` | `CertificationsSection` | `certifications` |
| `references_section.dart` | `ReferencesSection` | `references` |
| `custom_section.dart` | `CustomSectionWidget` | `custom_*` (dynamic id) |

---

## 7. How Data Flows (A Keystroke's Journey)
1. User types in a `TextField` inside a section widget (e.g., `ExperienceSection`).
2. The `onChanged` callback calls a method on `CVProvider` (e.g., `updateExperience`).
3. `CVProvider` updates the `CVData` object and calls `_notifyAndSave()`.
4. `_notifyAndSave()` tells the `PersistenceService` to save to Hive.
5. `_notifyAndSave()` also calls `notifyListeners()`.
6. `preview_section.dart` hears the notification and triggers a refresh of the PDF preview.

For **rich text fields**, `RichTextEditorField` calls `onChanged` with a JSON delta string every time the Quill document changes.

---

## 8. Quick Reference: "Where do I touch?"
| To Change... | File to Edit |
| :--- | :--- |
| The design of the PDF | `lib/core/services/pdf_service.dart` |
| The color/font of the UI | `lib/main.dart` (ThemeData) |
| A specific section's form UI | `lib/.../screens/sections/<section>_section.dart` |
| Adding a brand-new section type | `lib/core/models/cv_data.dart` → `cv_provider.dart` → create new section widget → register in `_buildSectionByKey` |
| The wording on the Dashboard | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| Persistence (Hive) settings | `lib/core/services/persistence_service.dart` |
| Personal Info / Header fields | `editor_screen.dart` (`_buildPersonalInfoSection`, `_buildHeaderSection`) |

---

> [!TIP]
> **Adding a new section**: Create a new `StatelessWidget` file in `screens/sections/`, use `Selector<CVProvider, ...>` for efficient rebuilds, use `RichTextEditorField` for any rich text, and use `ExpandableSectionTitle` as the `ExpansionTile` title. Then register it in `_buildSectionByKey` in `editor_screen.dart`.
