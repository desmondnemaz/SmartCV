import 'package:flutter/material.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';



class CVProvider with ChangeNotifier {
  CVData _cvData = _createDummyData();

  CVData get cvData => _cvData;

  static CVData _createDummyData() {
    return CVData(
      personalInfo: PersonalInfo(
        jobTitle: 'Senior Software Engineer',
        headerAlignment: 'left',
        showNameAsHeader: true,
        profileSummary: '[{"insert":"Experienced software engineer with a passion for developing innovative programs that expedite the efficiency and effectiveness of organizational success. Well-versed in technology and writing code to create systems that are reliable and user-friendly.\\n"}]',
        fields: [
          CVField(title: 'Name', value: 'John Doe', isCompulsory: true),
          CVField(title: 'Email', value: 'john.doe@example.com', isCompulsory: true),
          CVField(title: 'Phone', value: '+1 (555) 123-4567', isCompulsory: true),
          CVField(title: 'Address', value: 'San Francisco, CA, USA', isCompulsory: true),
          CVField(title: 'LinkedIn', value: 'linkedin.com/in/johndoe', isCompulsory: false),
          CVField(title: 'GitHub', value: 'github.com/johndoe', isCompulsory: false),
        ],
      ),
      education: [
        Education(
          institution: 'University of California, Berkeley',
          degree: 'Bachelor of Science in Computer Science',
          startDate: 'Aug 2015',
          endDate: 'May 2019',
          description: '[{"insert":"Graduated with Honors. Coursework included Data Structures, Algorithms, Database Systems, and Artificial Intelligence.\\n"}]',
        ),
      ],
      experience: [
        Experience(
          company: 'Tech Solutions Inc.',
          position: 'Software Engineer',
          startDate: 'Jun 2019',
          endDate: 'Present',
          description: '[{"insert":"• Developed and maintained web applications using React and Node.js.\\n• Collaborated with cross-functional teams to define, design, and ship new features.\\n• Improved application performance by 30% through code optimization.\\n"}]',
        ),
        Experience(
          company: 'InnovateTech',
          position: 'Junior Developer',
          startDate: 'Jan 2018',
          endDate: 'May 2019',
          description: '[{"insert":"• Assisted in the development of a mobile application using Flutter.\\n• Wrote unit and integration tests to ensure code quality.\\n• Participated in daily stand-ups and sprint planning meetings.\\n"}]',
        ),
      ],
      internships: [
        Internship(
          company: 'Google',
          position: 'Software Engineering Intern',
          startDate: 'May 2018',
          endDate: 'Aug 2018',
          description: '[{"insert":"• Contributed to the development of internal tools using Python and Go.\\n• Participated in code reviews and team meetings.\\n"}]',
        ),
      ],
      skills: [
        Skill(name: 'Dart & Flutter'),
        Skill(name: 'JavaScript / TypeScript'),
        Skill(name: 'React & Node.js'),
        Skill(name: 'Python & Django'),
        Skill(name: 'Git & GitHub'),
        Skill(name: 'Agile Methodologies'),
      ],
      certifications: [
        Certification(
          title: 'AWS Certified Solutions Architect',
          issuer: 'Amazon Web Services',
          date: 'Oct 2021',
          description: '[{"insert":"Demonstrated expertise in designing distributed systems on AWS.\\n"}]',
          isCompleted: true,
        ),
      ],
      references: [
        Reference(
          name: 'Jane Smith',
          position: 'Engineering Manager',
          company: 'Tech Solutions Inc.',
          email: 'jane.smith@example.com',
          phone: '+1 (555) 987-6543',
        ),
      ],
    );
  }

  // --- Section Titles ---
  void updateSectionTitles(SectionTitles titles) {
    _cvData.sectionTitles = titles;
    notifyListeners();
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _cvData.sectionOrder.removeAt(oldIndex);
    _cvData.sectionOrder.insert(newIndex, item);
    notifyListeners();
  }

  // --- Personal Info ---
  void updatePersonalInfo(PersonalInfo info) {
    _cvData.personalInfo = info;
    notifyListeners();
  }

  // --- Education ---
  void addEducation(Education ed) {
    _cvData.education.add(ed);
    notifyListeners();
  }

  void updateEducation(int index, Education ed) {
    if (index >= 0 && index < _cvData.education.length) {
      _cvData.education[index] = ed;
      notifyListeners();
    }
  }

  void removeEducation(int index) {
    if (index >= 0 && index < _cvData.education.length) {
      _cvData.education.removeAt(index);
      notifyListeners();
    }
  }

  // --- Experience ---
  void addExperience(Experience exp) {
    _cvData.experience.add(exp);
    notifyListeners();
  }

  void updateExperience(int index, Experience exp) {
    if (index >= 0 && index < _cvData.experience.length) {
      _cvData.experience[index] = exp;
      notifyListeners();
    }
  }

  void removeExperience(int index) {
    if (index >= 0 && index < _cvData.experience.length) {
      _cvData.experience.removeAt(index);
      notifyListeners();
    }
  }

  // --- Internships ---
  void addInternship(Internship internship) {
    _cvData.internships.add(internship);
    notifyListeners();
  }

  void updateInternship(int index, Internship internship) {
    if (index >= 0 && index < _cvData.internships.length) {
      _cvData.internships[index] = internship;
      notifyListeners();
    }
  }

  void removeInternship(int index) {
    if (index >= 0 && index < _cvData.internships.length) {
      _cvData.internships.removeAt(index);
      notifyListeners();
    }
  }

  // --- References ---
  void addReference(Reference reference) {
    _cvData.references.add(reference);
    notifyListeners();
  }

  void updateReference(int index, Reference reference) {
    if (index >= 0 && index < _cvData.references.length) {
      _cvData.references[index] = reference;
      notifyListeners();
    }
  }

  void removeReference(int index) {
    if (index >= 0 && index < _cvData.references.length) {
      _cvData.references.removeAt(index);
      notifyListeners();
    }
  }

  // --- Skills ---
  void addSkill(Skill skill) {
    _cvData.skills.add(skill);
    notifyListeners();
  }

  void updateSkill(int index, Skill skill) {
    if (index >= 0 && index < _cvData.skills.length) {
      _cvData.skills[index] = skill;
      notifyListeners();
    }
  }

  void removeSkill(int index) {
    if (index >= 0 && index < _cvData.skills.length) {
      _cvData.skills.removeAt(index);
      notifyListeners();
    }
  }

  // --- Certifications ---
  void addCertification(Certification cert) {
    _cvData.certifications.add(cert);
    notifyListeners();
  }

  void updateCertification(int index, Certification cert) {
    if (index >= 0 && index < _cvData.certifications.length) {
      _cvData.certifications[index] = cert;
      notifyListeners();
    }
  }

  void removeCertification(int index) {
    if (index >= 0 && index < _cvData.certifications.length) {
      _cvData.certifications.removeAt(index);
      notifyListeners();
    }
  }

  // --- Custom Sections ---
  void addCustomSection(CustomSection section) {
    _cvData.customSections.add(section);
    _cvData.sectionOrder.add(section.id);
    notifyListeners();
  }

  void updateCustomSection(String id, CustomSection section) {
    final index = _cvData.customSections.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _cvData.customSections[index] = section;
      notifyListeners();
    }
  }

  void removeCustomSection(String id) {
    _cvData.customSections.removeWhere((s) => s.id == id);
    _cvData.sectionOrder.remove(id);
    notifyListeners();
  }

  // --- Font Size ---
  void updateBaseFontSize(double size) {
    _cvData.baseFontSize = size.clamp(10, 14);
    notifyListeners();
  }
  
  void updateLineHeight(double height) {
    _cvData.lineHeight = height;
    notifyListeners();
  }

  void updatePrimaryColor(String hex) {
    _cvData.primaryColorHex = hex;
    notifyListeners();
  }

  void updateFontFamily(String font) {
    _cvData.fontFamily = font;
    notifyListeners();
  }

  void updatePdfFileName(String name) {
    _cvData.pdfFileName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    notifyListeners();
  }


  // Clear all data
  void clearAll() {
    _cvData = CVData();
    notifyListeners();
  }
}
