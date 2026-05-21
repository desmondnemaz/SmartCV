import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/models/cover_letter_data.dart';

class PersistenceService {
  static const String _cvBoxName = 'cv_storage';
  static const String _cvListKey = 'cv_list';
  static const String _currentCvIdKey = 'current_cv_id';
  static const String _coverLetterListKey = 'cover_letter_list';
  static const String _currentCoverLetterIdKey = 'current_cover_letter_id';
  static const String _themeModeKey = 'theme_mode';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_cvBoxName);
  }

  static Box _getBox() => Hive.box(_cvBoxName);

  /// Saves a CV to the list.
  static Future<void> saveCV(CVData data) async {
    try {
      final box = _getBox();
      final List<dynamic> rawList = box.get(_cvListKey, defaultValue: []);
      final List<String> cvList = List<String>.from(rawList);
      
      final jsonString = jsonEncode(data.toJson());
      
      // Update existing or add new
      int index = -1;
      for (int i = 0; i < cvList.length; i++) {
        final existing = CVData.fromJson(jsonDecode(cvList[i]));
        if (existing.id == data.id) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        cvList[index] = jsonString;
      } else {
        cvList.add(jsonString);
      }

      await box.put(_cvListKey, cvList);
      await box.put(_currentCvIdKey, data.id);
      debugPrint('CV ${data.id} saved locally.');
    } catch (e) {
      debugPrint('Error saving CV: $e');
    }
  }

  /// Loads all saved CVs.
  static List<CVData> loadAllCVs() {
    try {
      final List<dynamic> rawList = _getBox().get(_cvListKey, defaultValue: []);
      return rawList.map((s) => CVData.fromJson(jsonDecode(s as String))).toList();
    } catch (e) {
      debugPrint('Error loading CVs: $e');
      return [];
    }
  }

  /// Loads the last edited CV ID.
  static String? getCurrentCvId() {
    return _getBox().get(_currentCvIdKey);
  }

  /// Deletes a CV by ID.
  static Future<void> deleteCV(String id) async {
    final List<dynamic> rawList = _getBox().get(_cvListKey, defaultValue: []);
    final List<String> cvList = List<String>.from(rawList);
    
    cvList.removeWhere((s) => CVData.fromJson(jsonDecode(s)).id == id);
    await _getBox().put(_cvListKey, cvList);
  }

  /// Saves a Cover Letter to the list.
  static Future<void> saveCoverLetter(CoverLetterData data) async {
    try {
      final box = _getBox();
      final List<dynamic> rawList = box.get(_coverLetterListKey, defaultValue: []);
      final List<String> clList = List<String>.from(rawList);
      
      final jsonString = jsonEncode(data.toJson());
      
      // Update existing or add new
      int index = -1;
      for (int i = 0; i < clList.length; i++) {
        final existing = CoverLetterData.fromJson(jsonDecode(clList[i]));
        if (existing.id == data.id) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        clList[index] = jsonString;
      } else {
        clList.add(jsonString);
      }

      await box.put(_coverLetterListKey, clList);
      await box.put(_currentCoverLetterIdKey, data.id);
      debugPrint('Cover Letter ${data.id} saved locally.');
    } catch (e) {
      debugPrint('Error saving Cover Letter: $e');
    }
  }

  /// Loads all saved Cover Letters.
  static List<CoverLetterData> loadAllCoverLetters() {
    try {
      final List<dynamic> rawList = _getBox().get(_coverLetterListKey, defaultValue: []);
      return rawList.map((s) => CoverLetterData.fromJson(jsonDecode(s as String))).toList();
    } catch (e) {
      debugPrint('Error loading Cover Letters: $e');
      return [];
    }
  }

  /// Loads the last edited Cover Letter ID.
  static String? getCurrentCoverLetterId() {
    return _getBox().get(_currentCoverLetterIdKey);
  }

  /// Deletes a Cover Letter by ID.
  static Future<void> deleteCoverLetter(String id) async {
    final List<dynamic> rawList = _getBox().get(_coverLetterListKey, defaultValue: []);
    final List<String> clList = List<String>.from(rawList);
    
    clList.removeWhere((s) => CoverLetterData.fromJson(jsonDecode(s)).id == id);
    await _getBox().put(_coverLetterListKey, clList);
  }

  /// Saves the user's theme preference.
  static Future<void> saveThemeMode(String mode) async {
    await _getBox().put(_themeModeKey, mode);
  }

  /// Loads the user's theme preference.
  static String? loadThemeMode() {
    return _getBox().get(_themeModeKey);
  }

  /// Clears all saved data (useful for logout or reset).
  static Future<void> clearAll() async {
    await _getBox().clear();
  }
}
