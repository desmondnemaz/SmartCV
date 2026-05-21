import 'package:flutter/material.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/models/cover_letter_data.dart';
import 'package:smartcv_builder/core/services/persistence_service.dart';

class CoverLetterProvider with ChangeNotifier {
  CoverLetterData _coverLetterData = CoverLetterData(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    pdfFileName: 'New_Cover_Letter',
  );
  List<CoverLetterData> _savedCoverLetters = [];

  CoverLetterProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _savedCoverLetters = PersistenceService.loadAllCoverLetters();
    final currentId = PersistenceService.getCurrentCoverLetterId();

    if (_savedCoverLetters.isEmpty) {
      // Initialize in memory only, do not save to database yet
      _coverLetterData = CoverLetterData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pdfFileName: 'New_Cover_Letter',
      );
    } else {
      if (currentId != null) {
        final foundIndex = _savedCoverLetters.indexWhere((cl) => cl.id == currentId);
        if (foundIndex != -1) {
          _coverLetterData = _savedCoverLetters[foundIndex];
        } else {
          _coverLetterData = _savedCoverLetters.first;
        }
      } else {
        _coverLetterData = _savedCoverLetters.first;
      }
    }
  }

  CoverLetterData get coverLetterData => _coverLetterData;
  List<CoverLetterData> get savedCoverLetters => _savedCoverLetters;

  /// Helper to check if current cover letter is entirely empty.
  bool get isCurrentCoverLetterEmpty {
    final cl = _coverLetterData;
    final bodyRaw = cl.body.trim();
    final bodyEmpty = bodyRaw.isEmpty ||
        bodyRaw == '[{"insert":"\\n"}]' ||
        bodyRaw == '[{"insert":"\n"}]';
    final otherEmpty = cl.subjectLine.trim().isEmpty;

    return bodyEmpty && otherEmpty;
  }

  Future<void> _notifyAndSave() async {
    _coverLetterData.lastModified = DateTime.now();
    notifyListeners();
    await PersistenceService.saveCoverLetter(_coverLetterData);
    _savedCoverLetters = PersistenceService.loadAllCoverLetters();
  }

  Future<void> saveCurrentCoverLetter() async {
    await _notifyAndSave();
  }

  void createNewCoverLetter() {
    _coverLetterData = CoverLetterData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pdfFileName: 'Cover_Letter_${DateTime.now().millisecondsSinceEpoch}',
    );
    _notifyAndSave();
  }

  void loadCoverLetter(String id) {
    final foundIndex = _savedCoverLetters.indexWhere((cl) => cl.id == id);
    if (foundIndex != -1) {
      _coverLetterData = _savedCoverLetters[foundIndex];
      _notifyAndSave();
    }
  }

  Future<void> deleteCoverLetter(String id) async {
    await PersistenceService.deleteCoverLetter(id);
    _savedCoverLetters = PersistenceService.loadAllCoverLetters();
    if (_coverLetterData.id == id) {
      if (_savedCoverLetters.isNotEmpty) {
        _coverLetterData = _savedCoverLetters.first;
      } else {
        _coverLetterData = CoverLetterData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          pdfFileName: 'Untitled_Cover_Letter',
        );
      }
    }
    notifyListeners();
  }

  Future<void> discardCurrentCoverLetter() async {
    final idToDelete = _coverLetterData.id;
    await PersistenceService.deleteCoverLetter(idToDelete);
    _savedCoverLetters = PersistenceService.loadAllCoverLetters();
    if (_savedCoverLetters.isNotEmpty) {
      _coverLetterData = _savedCoverLetters.first;
    } else {
      _coverLetterData = CoverLetterData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pdfFileName: 'New_Cover_Letter',
      );
    }
    notifyListeners();
  }

  // --- Linked CV Sync Methods ---
  void syncWithLinkedCV(List<CVData> savedCVs) {
    if (_coverLetterData.linkedCvId == null) return;
    
    final cvIndex = savedCVs.indexWhere((cv) => cv.id == _coverLetterData.linkedCvId);
    if (cvIndex != -1) {
      final cv = savedCVs[cvIndex];

      // Update sender details from linked CV
      _coverLetterData.senderName = cv.personalInfo.fullName;
      _coverLetterData.senderJobTitle = cv.personalInfo.jobTitle;
      _coverLetterData.senderEmail = cv.personalInfo.email;
      
      final phoneField = cv.personalInfo.fields.firstWhere(
        (f) => f.title.toLowerCase() == 'phone',
        orElse: () => CVField(title: 'Phone'),
      );
      _coverLetterData.senderPhone = phoneField.value;
      
      final addressField = cv.personalInfo.fields.firstWhere(
        (f) => f.title.toLowerCase() == 'address',
        orElse: () => CVField(title: 'Address'),
      );
      _coverLetterData.senderAddress = addressField.value;

      // Update styling from linked CV
      _coverLetterData.templateId = cv.templateId;
      _coverLetterData.primaryColorHex = cv.primaryColorHex;
      _coverLetterData.fontFamily = cv.fontFamily;
      _coverLetterData.baseFontSize = (cv.baseFontSize + 1.0).clamp(10, 14); // Cover letters body slightly larger
      _coverLetterData.lineHeight = cv.lineHeight;
      _coverLetterData.headerAlignment = cv.personalInfo.headerAlignment;
      _coverLetterData.showNameAsHeader = cv.personalInfo.showNameAsHeader;
      
      _notifyAndSave();
    }
  }

  void updateLinkedCvId(String? cvId, List<CVData> savedCVs) {
    _coverLetterData.linkedCvId = cvId;
    if (cvId != null) {
      syncWithLinkedCV(savedCVs);
    } else {
      // Clear sender details when unlinked to prevent stale template data
      _coverLetterData.senderName = '';
      _coverLetterData.senderJobTitle = '';
      _coverLetterData.senderEmail = '';
      _coverLetterData.senderPhone = '';
      _coverLetterData.senderAddress = '';
      _notifyAndSave();
    }
  }

  // --- Field Mutators ---
  void updatePdfFileName(String name) {
    _coverLetterData.pdfFileName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    _notifyAndSave();
  }

  void updateSenderDetails({
    required String name,
    required String jobTitle,
    required String email,
    required String phone,
    required String address,
  }) {
    // Only allow editing if unlinked
    if (_coverLetterData.linkedCvId != null) return;
    
    _coverLetterData.senderName = name;
    _coverLetterData.senderJobTitle = jobTitle;
    _coverLetterData.senderEmail = email;
    _coverLetterData.senderPhone = phone;
    _coverLetterData.senderAddress = address;
    _notifyAndSave();
  }

  void updateLetterDetails({
    required String date,
    required String subjectLine,
  }) {
    _coverLetterData.date = date;
    _coverLetterData.subjectLine = subjectLine;
    _notifyAndSave();
  }

  void updateBody(String bodyJson) {
    _coverLetterData.body = bodyJson;
    _notifyAndSave();
  }

  void updateStyling({
    String? templateId,
    String? primaryColorHex,
    String? fontFamily,
    double? baseFontSize,
    double? lineHeight,
    String? headerAlignment,
    bool? showNameAsHeader,
  }) {
    // Only allow editing if unlinked
    if (_coverLetterData.linkedCvId != null) return;

    if (templateId != null) _coverLetterData.templateId = templateId;
    if (primaryColorHex != null) _coverLetterData.primaryColorHex = primaryColorHex;
    if (fontFamily != null) _coverLetterData.fontFamily = fontFamily;
    if (baseFontSize != null) _coverLetterData.baseFontSize = baseFontSize.clamp(10, 14);
    if (lineHeight != null) _coverLetterData.lineHeight = lineHeight;
    if (headerAlignment != null) _coverLetterData.headerAlignment = headerAlignment;
    if (showNameAsHeader != null) _coverLetterData.showNameAsHeader = showNameAsHeader;
    _notifyAndSave();
  }

  void clearAll() {
    _coverLetterData = CoverLetterData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pdfFileName: 'Untitled_Cover_Letter',
    );
    _notifyAndSave();
  }
}
