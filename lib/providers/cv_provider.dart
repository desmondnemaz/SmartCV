import 'package:flutter/material.dart';
import '../data/models/cv_data.dart';

class CVProvider with ChangeNotifier {
  CVData _cvData = CVData();

  CVData get cvData => _cvData;

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

  // Clear all data
  void clearAll() {
    _cvData = CVData();
    notifyListeners();
  }
}
