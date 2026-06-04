import 'package:flutter/material.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/services/persistence_service.dart';



class CVProvider with ChangeNotifier {
  CVData _cvData = _createDummyData();
  List<CVData> _savedCVs = [];

  CVProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _savedCVs = PersistenceService.loadAllCVs();
    final currentId = PersistenceService.getCurrentCvId();
    
    if (_savedCVs.isEmpty) {
      // Start with a fresh blank CV in memory, but don't save to persistence yet
      _cvData = CVData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pdfFileName: 'Untitled_CV',
      );
    } else {
      if (currentId != null) {
        final foundIndex = _savedCVs.indexWhere((cv) => cv.id == currentId);
        if (foundIndex != -1) {
          _cvData = _savedCVs[foundIndex];
        } else {
          _cvData = _savedCVs.first;
        }
      } else {
        _cvData = _savedCVs.first;
      }
    }
  }

  CVData get cvData => _cvData;
  List<CVData> get savedCVs => _savedCVs;

  /// Returns true when the current CV has no meaningful user-entered content.
  bool get isCurrentCVEmpty {
    final info = _cvData.personalInfo;
    // Check all personal info fields are blank
    final fieldsEmpty = info.fields.every((f) => f.value.trim().isEmpty);
    // Check job title is blank
    final jobTitleEmpty = info.jobTitle.trim().isEmpty;
    // Check profile summary is blank (empty Quill doc is '[{"insert":"\n"}]' or '')
    final summaryRaw = info.profileSummary.trim();
    final summaryEmpty = summaryRaw.isEmpty ||
        summaryRaw == '[{"insert":"\\n"}]' ||
        summaryRaw == '[{"insert":"\n"}]';
    // Check all list sections are empty
    final sectionsEmpty = _cvData.experience.isEmpty &&
        _cvData.education.isEmpty &&
        _cvData.skills.isEmpty &&
        _cvData.internships.isEmpty &&
        _cvData.projects.isEmpty &&
        _cvData.certifications.isEmpty &&
        _cvData.references.isEmpty &&
        _cvData.customSections.isEmpty;

    return fieldsEmpty && jobTitleEmpty && summaryEmpty && sectionsEmpty;
  }

  /// Deletes the current blank CV from storage and loads the next available one.
  Future<void> discardCurrentCV() async {
    final idToDelete = _cvData.id;
    await PersistenceService.deleteCV(idToDelete);
    _savedCVs = PersistenceService.loadAllCVs();
    if (_savedCVs.isNotEmpty) {
      _cvData = _savedCVs.first;
    } else {
      // Just initialize in memory, don't save to persistence yet
      _cvData = CVData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pdfFileName: 'New_CV',
      );
    }
    notifyListeners();
  }

  // Custom notify wrapper to handle auto-save
  Future<void> _notifyAndSave() async {
    _cvData.lastModified = DateTime.now();
    notifyListeners();
    await PersistenceService.saveCV(_cvData);
    // Refresh the list
    _savedCVs = PersistenceService.loadAllCVs();
  }

  Future<void> saveCurrentCV() async {
    await _notifyAndSave();
  }

  String get lastModifiedFormatted {
    if (_cvData.lastModified == null) return 'Never';
    final date = _cvData.lastModified!;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void createNewCV() {
    _cvData = CVData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pdfFileName: 'New_CV_${DateTime.now().millisecondsSinceEpoch}',
    );
    _notifyAndSave();
  }

  void loadCV(String id) {
    final foundIndex = _savedCVs.indexWhere((cv) => cv.id == id);
    if (foundIndex != -1) {
      _cvData = _savedCVs[foundIndex];
      _notifyAndSave();
    } else if (id == 'example_john_doe') {
      _cvData = _createDummyData();
      _notifyAndSave();
    }
  }

  Future<void> deleteCV(String id) async {
    await PersistenceService.deleteCV(id);
    _savedCVs = PersistenceService.loadAllCVs();
    if (_cvData.id == id) {
      if (_savedCVs.isNotEmpty) {
        _cvData = _savedCVs.first;
      } else {
        // Just initialize in memory
        _cvData = CVData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          pdfFileName: 'Untitled_CV',
        );
      }
    }
    notifyListeners();
  }

  static CVData _createDummyData() {
    return CVData(
      id: 'example_john_doe',
      personalInfo: PersonalInfo(
        jobTitle: 'Senior Software Engineer',
        headerAlignment: 'left',
        showNameAsHeader: true,
        profileSummary: '[{"insert":"Experienced software engineer with a passion for developing innovative programs that expedite the efficiency and effectiveness of organizational success. Well-versed in technology and writing code to create systems that are reliable and user-friendly. Dedicated to continuous learning and mentoring junior developers to foster a collaborative and high-performing team environment.\\n"}]',
        fields: [
          CVField(title: 'Name', value: 'John Doe', isCompulsory: true),
          CVField(title: 'Email', value: 'john.doe@example.com', isCompulsory: true),
          CVField(title: 'Phone', value: '+1 (555) 123-4567', isCompulsory: true),
          CVField(title: 'Address', value: 'San Francisco, CA, USA', isCompulsory: true),
          CVField(title: 'LinkedIn', value: 'linkedin.com/in/johndoe', isCompulsory: false),
          CVField(title: 'GitHub', value: 'github.com/johndoe', isCompulsory: false),
          CVField(title: 'Website', value: 'johndoe.dev', isCompulsory: false),
        ],
      ),
      education: [
        Education(
          institution: 'University of California, Berkeley',
          degree: 'Master of Science in Computer Science',
          startDate: 'Aug 2019',
          endDate: 'May 2021',
          description: '[{"insert":"Specialized in Machine Learning and Artificial Intelligence. Thesis on predictive models for healthcare.\\n"}]',
        ),
        Education(
          institution: 'University of California, Berkeley',
          degree: 'Bachelor of Science in Computer Science',
          startDate: 'Aug 2015',
          endDate: 'May 2019',
          description: '[{"insert":"Graduated with Honors. Coursework included Data Structures, Algorithms, Database Systems, and Artificial Intelligence. President of the Computer Science Society.\\n"}]',
        ),
      ],
      experience: [
        Experience(
          company: 'Tech Solutions Inc.',
          position: 'Senior Software Engineer',
          startDate: 'Jan 2022',
          endDate: 'Present',
          description: '[{"insert":"Lead developer for the core microservices architecture using Go and Node.js."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Mentored a team of 5 junior and mid-level developers, improving overall team velocity by 25%."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Architected a scalable real-time data processing pipeline that handles 1M+ events per day."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
        Experience(
          company: 'InnovateTech',
          position: 'Software Engineer',
          startDate: 'Jun 2019',
          endDate: 'Dec 2021',
          description: '[{"insert":"Developed and maintained web applications using React and Node.js."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Collaborated with cross-functional teams to define, design, and ship new features."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Improved application performance by 30% through code optimization and database indexing."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Implemented robust CI/CD pipelines using GitHub Actions and Docker."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
        Experience(
          company: 'Startup Hub',
          position: 'Junior Developer',
          startDate: 'Jan 2018',
          endDate: 'May 2019',
          description: '[{"insert":"Assisted in the development of a mobile application using Flutter and Dart."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Wrote unit and integration tests to ensure code quality."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Participated in daily stand-ups and sprint planning meetings."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
      ],
      internships: [
        Internship(
          company: 'Google',
          position: 'Software Engineering Intern',
          startDate: 'May 2018',
          endDate: 'Aug 2018',
          description: '[{"insert":"Contributed to the development of internal tools using Python and Go."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Participated in code reviews and team meetings."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
      ],
      skills: [
        Skill(name: 'Dart & Flutter'),
        Skill(name: 'JavaScript / TypeScript'),
        Skill(name: 'React & Next.js'),
        Skill(name: 'Node.js & Express'),
        Skill(name: 'Python & Django'),
        Skill(name: 'Go (Golang)'),
        Skill(name: 'SQL & PostgreSQL'),
        Skill(name: 'Docker & Kubernetes'),
        Skill(name: 'AWS & GCP Cloud Services'),
        Skill(name: 'Git & CI/CD'),
        Skill(name: 'Agile Methodologies'),
        Skill(name: 'System Architecture'),
      ],
      certifications: [
        Certification(
          title: 'AWS Certified Solutions Architect',
          issuer: 'Amazon Web Services',
          date: 'Oct 2021',
          description: '[{"insert":"Demonstrated expertise in designing distributed systems on AWS.\\n"}]',
          isCompleted: true,
        ),
        Certification(
          title: 'Google Cloud Professional Cloud Architect',
          issuer: 'Google Cloud',
          date: 'Mar 2023',
          description: '[{"insert":"Certified in designing, developing, and managing robust, secure, and dynamic solutions to drive business objectives.\\n"}]',
          isCompleted: true,
        ),
      ],
      references: [
        Reference(
          name: 'Jane Smith',
          position: 'Director of Engineering',
          company: 'Tech Solutions Inc.',
          email: 'jane.smith@example.com',
          phone: '+1 (555) 987-6543',
        ),
        Reference(
          name: 'Robert Johnson',
          position: 'Senior Product Manager',
          company: 'InnovateTech',
          email: 'robert.johnson@example.com',
          phone: '+1 (555) 111-2222',
        ),
      ],
      projects: [
        Project(
          title: 'SmartCV Builder',
          link: 'smartcv-zw.web.app',
          startDate: 'Apr 2024',
          endDate: 'Present',
          description: '[{"insert":"Open-source Flutter application for building professional CVs with live PDF preview."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Implemented complex state management using Provider."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Integrated pdf generation with custom themes and robust customizable sections."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
        Project(
          title: 'E-commerce Platform API',
          link: 'github.com/johndoe/ecommerce-api',
          startDate: 'Jan 2023',
          endDate: 'Jun 2023',
          description: '[{"insert":"RESTful API built with Node.js, Express, and PostgreSQL."},{"attributes":{"list":"bullet"},"insert":"\\n"},{"insert":"Features include user authentication, product management, and payment processing integration."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
        Project(
          title: 'Real-time Chat Application',
          link: 'github.com/johndoe/realtime-chat',
          startDate: 'Sep 2021',
          endDate: 'Dec 2021',
          description: '[{"insert":"Real-time messaging application built with React, Node.js, and Socket.io. Deployed on AWS."},{"attributes":{"list":"bullet"},"insert":"\\n"}]',
        ),
      ],
    );
  }

  // --- Section Titles ---
  void updateSectionTitles(SectionTitles titles) {
    _cvData.sectionTitles = titles;
    _notifyAndSave();
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _cvData.sectionOrder.removeAt(oldIndex);
    _cvData.sectionOrder.insert(newIndex, item);
    _notifyAndSave();
  }

  void addSection(String key) {
    if (!_cvData.sectionOrder.contains(key)) {
      _cvData.sectionOrder.add(key);
      _notifyAndSave();
    }
  }

  void removeSection(String key) {
    if (_cvData.sectionOrder.contains(key)) {
      _cvData.sectionOrder.remove(key);
      _cvData.pageBreaks.remove(key);
      _notifyAndSave();
    }
  }

  void togglePageBreak(String key) {
    if (_cvData.pageBreaks.contains(key)) {
      _cvData.pageBreaks.remove(key);
    } else {
      _cvData.pageBreaks.add(key);
    }
    _notifyAndSave();
  }

  // --- Personal Info ---
  void updatePersonalInfo(PersonalInfo info) {
    _cvData.personalInfo = info;
    _notifyAndSave();
  }

  // --- Education ---
  void addEducation(Education ed) {
    _cvData.education.add(ed);
    _notifyAndSave();
  }

  void updateEducation(int index, Education ed) {
    if (index >= 0 && index < _cvData.education.length) {
      _cvData.education[index] = ed;
      _notifyAndSave();
    }
  }

  void removeEducation(int index) {
    if (index >= 0 && index < _cvData.education.length) {
      _cvData.education.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Experience ---
  void addExperience(Experience exp) {
    _cvData.experience.add(exp);
    _notifyAndSave();
  }

  void updateExperience(int index, Experience exp) {
    if (index >= 0 && index < _cvData.experience.length) {
      _cvData.experience[index] = exp;
      _notifyAndSave();
    }
  }

  void removeExperience(int index) {
    if (index >= 0 && index < _cvData.experience.length) {
      _cvData.experience.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Internships ---
  void addInternship(Internship internship) {
    _cvData.internships.add(internship);
    _notifyAndSave();
  }

  void updateInternship(int index, Internship internship) {
    if (index >= 0 && index < _cvData.internships.length) {
      _cvData.internships[index] = internship;
      _notifyAndSave();
    }
  }

  void removeInternship(int index) {
    if (index >= 0 && index < _cvData.internships.length) {
      _cvData.internships.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- References ---
  void addReference(Reference reference) {
    _cvData.references.add(reference);
    _notifyAndSave();
  }

  void updateReference(int index, Reference reference) {
    if (index >= 0 && index < _cvData.references.length) {
      _cvData.references[index] = reference;
      _notifyAndSave();
    }
  }

  void removeReference(int index) {
    if (index >= 0 && index < _cvData.references.length) {
      _cvData.references.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Skills ---
  void addSkill(Skill skill) {
    _cvData.skills.add(skill);
    _notifyAndSave();
  }

  void updateSkill(int index, Skill skill) {
    if (index >= 0 && index < _cvData.skills.length) {
      _cvData.skills[index] = skill;
      _notifyAndSave();
    }
  }

  void removeSkill(int index) {
    if (index >= 0 && index < _cvData.skills.length) {
      _cvData.skills.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Certifications ---
  void addCertification(Certification cert) {
    _cvData.certifications.add(cert);
    _notifyAndSave();
  }

  void updateCertification(int index, Certification cert) {
    if (index >= 0 && index < _cvData.certifications.length) {
      _cvData.certifications[index] = cert;
      _notifyAndSave();
    }
  }

  void removeCertification(int index) {
    if (index >= 0 && index < _cvData.certifications.length) {
      _cvData.certifications.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Projects ---
  void addProject(Project project) {
    _cvData.projects.add(project);
    _notifyAndSave();
  }

  void updateProject(int index, Project project) {
    if (index >= 0 && index < _cvData.projects.length) {
      _cvData.projects[index] = project;
      _notifyAndSave();
    }
  }

  void removeProject(int index) {
    if (index >= 0 && index < _cvData.projects.length) {
      _cvData.projects.removeAt(index);
      _notifyAndSave();
    }
  }

  // --- Custom Sections ---
  void addCustomSection(CustomSection section) {
    _cvData.customSections.add(section);
    _cvData.sectionOrder.add(section.id);
    _notifyAndSave();
  }

  void updateCustomSection(String id, CustomSection section) {
    final index = _cvData.customSections.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _cvData.customSections[index] = section;
      _notifyAndSave();
    }
  }

  void removeCustomSection(String id) {
    _cvData.customSections.removeWhere((s) => s.id == id);
    _cvData.sectionOrder.remove(id);
    _notifyAndSave();
  }

  // --- Font Size ---
  void updateBaseFontSize(double size) {
    _cvData.baseFontSize = size.clamp(10, 14);
    _notifyAndSave();
  }
  
  void updateLineHeight(double height) {
    _cvData.lineHeight = height;
    _notifyAndSave();
  }

  void updatePrimaryColor(String hex) {
    _cvData.primaryColorHex = hex;
    _notifyAndSave();
  }

  void updateFontFamily(String font) {
    _cvData.fontFamily = font;
    _notifyAndSave();
  }

  void updatePdfFileName(String name) {
    _cvData.pdfFileName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    _notifyAndSave();
  }

  void changeTemplate(String templateId) {
    _cvData.templateId = templateId;
    _notifyAndSave();
  }
  // Clear all data
  void clearAll() {
    _cvData = CVData();
    _notifyAndSave();
  }
}
