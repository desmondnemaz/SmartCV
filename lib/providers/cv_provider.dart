import 'package:flutter/material.dart';
import '../data/models/cv_data.dart';

class CVProvider with ChangeNotifier {
  CVData _cvData = CVData();

  CVData get cvData => _cvData;

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

  // Clear all data
  void clearAll() {
    _cvData = CVData();
    notifyListeners();
  }
}
