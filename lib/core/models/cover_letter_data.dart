class CoverLetterData {
  final String id;
  String pdfFileName;
  String? linkedCvId;
  DateTime? lastModified;

  // Sender details (synced from linked resume)
  String senderName;
  String senderJobTitle;
  String senderEmail;
  String senderPhone;
  String senderAddress;

  // Letter content
  String date;
  String subjectLine;
  String body; // Rich text (Quill Delta JSON)

  // Formatting variables
  String templateId;
  String primaryColorHex;
  String fontFamily;
  double baseFontSize;
  double lineHeight;
  String headerAlignment; // 'left', 'center', 'right'
  bool showNameAsHeader;

  CoverLetterData({
    required this.id,
    this.pdfFileName = 'Untitled_Cover_Letter',
    this.linkedCvId,
    this.lastModified,
    this.senderName = '',
    this.senderJobTitle = '',
    this.senderEmail = '',
    this.senderPhone = '',
    this.senderAddress = '',
    this.date = '',
    this.subjectLine = '',
    this.body = '',
    this.templateId = 'default',
    this.primaryColorHex = '#0D47A1',
    this.fontFamily = 'Poppins',
    this.baseFontSize = 11.0,
    this.lineHeight = 1.15,
    this.headerAlignment = 'left',
    this.showNameAsHeader = true,
  }) {
    if (body.isEmpty) {
      body = _defaultBodyDelta;
    }
  }

  static const String _defaultBodyDelta =
      '[{"insert":"[Date]\\n\\n[Recipient Name]\\n[Recipient Job Title]\\n[Recipient Company]\\n[Recipient Address]\\n\\n"},{"insert":"RE: [SUBJECT LINE / POSITION TITLE]\\n\\n","attributes":{"bold":true}},{"insert":"Dear Hiring Manager,\\n\\nI am writing to express my interest in the [Job Title] position at [Company]. With my background in [Field] and experience in [Skills], I am confident I would be a great fit for your team.\\n\\nIn my previous projects, I successfully [describe an achievement]. This allowed me to develop skills in [mention 1-2 skills] that align directly with your requirements.\\n\\nThank you for your time and consideration. I look forward to discussing how my background fits your needs.\\n\\nSincerely,\\n\\n[Your Name]\\n"}]';

  String get lastModifiedFormatted {
    if (lastModified == null) return 'Never';
    final date = lastModified!;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pdfFileName': pdfFileName,
        'linkedCvId': linkedCvId,
        'lastModified': lastModified?.toIso8601String(),
        'senderName': senderName,
        'senderJobTitle': senderJobTitle,
        'senderEmail': senderEmail,
        'senderPhone': senderPhone,
        'senderAddress': senderAddress,
        'date': date,
        'subjectLine': subjectLine,
        'body': body,
        'templateId': templateId,
        'primaryColorHex': primaryColorHex,
        'fontFamily': fontFamily,
        'baseFontSize': baseFontSize,
        'lineHeight': lineHeight,
        'headerAlignment': headerAlignment,
        'showNameAsHeader': showNameAsHeader,
      };

  factory CoverLetterData.fromJson(Map<String, dynamic> json) => CoverLetterData(
        id: json['id'] ?? '',
        pdfFileName: json['pdfFileName'] ?? 'Untitled_Cover_Letter',
        linkedCvId: json['linkedCvId'],
        lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
        senderName: json['senderName'] ?? '',
        senderJobTitle: json['senderJobTitle'] ?? '',
        senderEmail: json['senderEmail'] ?? '',
        senderPhone: json['senderPhone'] ?? '',
        senderAddress: json['senderAddress'] ?? '',
        date: json['date'] ?? '',
        subjectLine: json['subjectLine'] ?? '',
        body: json['body'] ?? '',
        templateId: json['templateId'] ?? 'default',
        primaryColorHex: json['primaryColorHex'] ?? '#0D47A1',
        fontFamily: json['fontFamily'] ?? 'Poppins',
        baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 11.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.15,
        headerAlignment: json['headerAlignment'] ?? 'left',
        showNameAsHeader: json['showNameAsHeader'] ?? true,
      );

  CoverLetterData copyWith({
    String? id,
    String? pdfFileName,
    String? linkedCvId,
    DateTime? lastModified,
    String? senderName,
    String? senderJobTitle,
    String? senderEmail,
    String? senderPhone,
    String? senderAddress,
    String? date,
    String? subjectLine,
    String? body,
    String? templateId,
    String? primaryColorHex,
    String? fontFamily,
    double? baseFontSize,
    double? lineHeight,
    String? headerAlignment,
    bool? showNameAsHeader,
  }) {
    return CoverLetterData(
      id: id ?? this.id,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      linkedCvId: linkedCvId, // Allows explicitly setting to null
      lastModified: lastModified ?? this.lastModified,
      senderName: senderName ?? this.senderName,
      senderJobTitle: senderJobTitle ?? this.senderJobTitle,
      senderEmail: senderEmail ?? this.senderEmail,
      senderPhone: senderPhone ?? this.senderPhone,
      senderAddress: senderAddress ?? this.senderAddress,
      date: date ?? this.date,
      subjectLine: subjectLine ?? this.subjectLine,
      body: body ?? this.body,
      templateId: templateId ?? this.templateId,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      fontFamily: fontFamily ?? this.fontFamily,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      headerAlignment: headerAlignment ?? this.headerAlignment,
      showNameAsHeader: showNameAsHeader ?? this.showNameAsHeader,
    );
  }
}
