class CVField {
  String title;
  String value;
  bool isCompulsory;

  CVField({
    required this.title,
    this.value = '',
    this.isCompulsory = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'value': value,
        'isCompulsory': isCompulsory,
      };

  factory CVField.fromJson(Map<String, dynamic> json) => CVField(
        title: json['title'] ?? '',
        value: json['value'] ?? '',
        isCompulsory: json['isCompulsory'] ?? false,
      );
}

class PersonalInfo {
  String jobTitle;
  String headerAlignment; // 'left', 'center', 'right'
  List<CVField> fields;
  String profileSummary;
  bool showNameAsHeader;

  PersonalInfo({
    this.jobTitle = '',
    this.headerAlignment = 'left',
    List<CVField>? fields,
    this.profileSummary = '',
    this.showNameAsHeader = false,
  }) : fields = fields ?? [
          CVField(title: 'Name', isCompulsory: true),
          CVField(title: 'Email', isCompulsory: true),
          CVField(title: 'Phone', isCompulsory: true),
          CVField(title: 'Address', isCompulsory: true),
        ];

  Map<String, dynamic> toJson() => {
        'jobTitle': jobTitle,
        'headerAlignment': headerAlignment,
        'fields': fields.map((e) => e.toJson()).toList(),
        'profileSummary': profileSummary,
        'showNameAsHeader': showNameAsHeader,
      };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
        jobTitle: json['jobTitle'] ?? '',
        headerAlignment: json['headerAlignment'] ?? 'left',
        fields: (json['fields'] as List?)?.map((e) => CVField.fromJson(e)).toList(),
        profileSummary: json['profileSummary'] ?? '',
        showNameAsHeader: json['showNameAsHeader'] ?? false,
      );

  // Helper getters for compatibility if needed, though we should migrate
  String get fullName => fields.isNotEmpty ? fields[0].value : '';
  String get email => fields.length > 1 ? fields[1].value : '';
}

class Education {
  String institution;
  String degree;
  String startDate;
  String endDate;
  String description;

  Education({
    this.institution = '',
    this.degree = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'institution': institution,
        'degree': degree,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        institution: json['institution'] ?? '',
        degree: json['degree'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        description: json['description'] ?? '',
      );
}

class Experience {
  String company;
  String position;
  String startDate;
  String endDate;
  String description;

  Experience({
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'company': company,
        'position': position,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        company: json['company'] ?? '',
        position: json['position'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        description: json['description'] ?? '',
      );
}

class Internship {
  String company;
  String position;
  String startDate;
  String endDate;
  String description;

  Internship({
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'company': company,
        'position': position,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

  factory Internship.fromJson(Map<String, dynamic> json) => Internship(
        company: json['company'] ?? '',
        position: json['position'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        description: json['description'] ?? '',
      );
}

class Reference {
  String name;
  String position;
  String company;
  String email;
  String phone;

  Reference({
    this.name = '',
    this.position = '',
    this.company = '',
    this.email = '',
    this.phone = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'company': company,
        'email': email,
        'phone': phone,
      };

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
        name: json['name'] ?? '',
        position: json['position'] ?? '',
        company: json['company'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
      );
}

class Skill {
  String name;

  Skill({
    this.name = '',
  });

  Map<String, dynamic> toJson() => {'name': name};

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        name: json['name'] ?? '',
      );
}

class Project {
  String title;
  String link;
  String description;
  String startDate;
  String endDate;

  Project({
    this.title = '',
    this.link = '',
    this.description = '',
    this.startDate = '',
    this.endDate = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        title: json['title'] ?? '',
        link: json['link'] ?? '',
        description: json['description'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
      );
}

class Certification {
  String title;
  String issuer;
  String date;
  String description;
  bool isCompleted;

  Certification({
    this.title = '',
    this.issuer = '',
    this.date = '',
    this.description = '',
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'issuer': issuer,
        'date': date,
        'description': description,
        'isCompleted': isCompleted,
      };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        title: json['title'] ?? '',
        issuer: json['issuer'] ?? '',
        date: json['date'] ?? '',
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? true,
      );
}

class CustomSection {
  String id;
  String title;
  String description;
  bool isVisible;

  CustomSection({
    required this.id,
    this.title = 'Custom Section',
    this.description = '',
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isVisible': isVisible,
      };

  factory CustomSection.fromJson(Map<String, dynamic> json) => CustomSection(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        isVisible: json['isVisible'] ?? true,
      );

  CustomSection copyWith({
    String? id,
    String? title,
    String? description,
    bool? isVisible,
  }) {
    return CustomSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class SectionTitles {
  String personalInfo;
  bool showPersonalInfo;
  String professionalSummary;
  bool showProfessionalSummary;
  String experience;
  bool showExperience;
  String internships;
  bool showInternships;
  String education;
  bool showEducation;
  String skills;
  bool showSkills;
  String certifications;
  bool showCertifications;
  String references;
  bool showReferences;
  String projects;
  bool showProjects;

  SectionTitles({
    this.personalInfo = 'Personal Information',
    this.showPersonalInfo = true,
    this.professionalSummary = 'Professional Summary',
    this.showProfessionalSummary = true,
    this.experience = 'Experience',
    this.showExperience = true,
    this.internships = 'Internships',
    this.showInternships = true,
    this.education = 'Education',
    this.showEducation = true,
    this.skills = 'Skills',
    this.showSkills = true,
    this.certifications = 'Certifications',
    this.showCertifications = true,
    this.references = 'References',
    this.showReferences = true,
    this.projects = 'Projects',
    this.showProjects = true,
  });

  Map<String, dynamic> toJson() => {
        'personalInfo': personalInfo,
        'showPersonalInfo': showPersonalInfo,
        'professionalSummary': professionalSummary,
        'showProfessionalSummary': showProfessionalSummary,
        'experience': experience,
        'showExperience': showExperience,
        'internships': internships,
        'showInternships': showInternships,
        'education': education,
        'showEducation': showEducation,
        'skills': skills,
        'showSkills': showSkills,
        'certifications': certifications,
        'showCertifications': showCertifications,
        'references': references,
        'showReferences': showReferences,
        'projects': projects,
        'showProjects': showProjects,
      };

  factory SectionTitles.fromJson(Map<String, dynamic> json) => SectionTitles(
        personalInfo: json['personalInfo'] ?? 'Personal Information',
        showPersonalInfo: json['showPersonalInfo'] ?? true,
        professionalSummary: json['professionalSummary'] ?? 'Professional Summary',
        showProfessionalSummary: json['showProfessionalSummary'] ?? true,
        experience: json['experience'] ?? 'Experience',
        showExperience: json['showExperience'] ?? true,
        internships: json['internships'] ?? 'Internships',
        showInternships: json['showInternships'] ?? true,
        education: json['education'] ?? 'Education',
        showEducation: json['showEducation'] ?? true,
        skills: json['skills'] ?? 'Skills',
        showSkills: json['showSkills'] ?? true,
        certifications: json['certifications'] ?? 'Certifications',
        showCertifications: json['showCertifications'] ?? true,
        references: json['references'] ?? 'References',
        showReferences: json['showReferences'] ?? true,
        projects: json['projects'] ?? 'Projects',
        showProjects: json['showProjects'] ?? true,
      );

  SectionTitles copyWith({
    String? personalInfo,
    bool? showPersonalInfo,
    String? professionalSummary,
    bool? showProfessionalSummary,
    String? experience,
    bool? showExperience,
    String? internships,
    bool? showInternships,
    String? education,
    bool? showEducation,
    String? skills,
    bool? showSkills,
    String? certifications,
    bool? showCertifications,
    String? references,
    bool? showReferences,
    String? projects,
    bool? showProjects,
  }) {
    return SectionTitles(
      personalInfo: personalInfo ?? this.personalInfo,
      showPersonalInfo: showPersonalInfo ?? this.showPersonalInfo,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      showProfessionalSummary: showProfessionalSummary ?? this.showProfessionalSummary,
      experience: experience ?? this.experience,
      showExperience: showExperience ?? this.showExperience,
      internships: internships ?? this.internships,
      showInternships: showInternships ?? this.showInternships,
      education: education ?? this.education,
      showEducation: showEducation ?? this.showEducation,
      skills: skills ?? this.skills,
      showSkills: showSkills ?? this.showSkills,
      certifications: certifications ?? this.certifications,
      showCertifications: showCertifications ?? this.showCertifications,
      references: references ?? this.references,
      showReferences: showReferences ?? this.showReferences,
      projects: projects ?? this.projects,
      showProjects: showProjects ?? this.showProjects,
    );
  }
}

class CVData {
  PersonalInfo personalInfo;
  SectionTitles sectionTitles;
  List<Education> education;
  List<Experience> experience;
  List<Internship> internships;
  List<Reference> references;
  List<Skill> skills;
  List<Certification> certifications;
  List<Project> projects;
  List<CustomSection> customSections;
  List<String> sectionOrder;
  List<String> pageBreaks;
  double baseFontSize;
  double lineHeight;
  String primaryColorHex;
  String fontFamily;
  String pdfFileName;
  String templateId;
  String id;
  DateTime? lastModified;

  String get lastModifiedFormatted {
    if (lastModified == null) return 'Never';
    final date = lastModified!;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  CVData({
    this.id = 'default_cv',
    PersonalInfo? personalInfo,
    SectionTitles? sectionTitles,
    List<Education>? education,
    List<Experience>? experience,
    List<Internship>? internships,
    List<Reference>? references,
    List<Skill>? skills,
    List<Certification>? certifications,
    List<Project>? projects,
    List<CustomSection>? customSections,
    List<String>? sectionOrder,
    List<String>? pageBreaks,
    this.baseFontSize = 10.0,
    this.lineHeight = 1.0,
    this.primaryColorHex = '#0D47A1',
    this.fontFamily = 'Poppins',
    this.pdfFileName = '',
    this.templateId = 'default',
    this.lastModified,

  })  : personalInfo = personalInfo ?? PersonalInfo(),

        sectionTitles = sectionTitles ?? SectionTitles(),
        education = education ?? [],
        experience = experience ?? [],
        internships = internships ?? [],
        references = references ?? [],
        skills = skills ?? [],
        certifications = certifications ?? [],
        projects = projects ?? [],
        customSections = customSections ?? [],
        pageBreaks = pageBreaks ?? [],
        sectionOrder = sectionOrder ?? [
          'personalInfo',
          'professionalSummary',
          'experience',
          'education',
          'skills',
        ];

  Map<String, dynamic> toJson() => {
        'personalInfo': personalInfo.toJson(),
        'sectionTitles': sectionTitles.toJson(),
        'education': education.map((e) => e.toJson()).toList(),
        'experience': experience.map((e) => e.toJson()).toList(),
        'internships': internships.map((e) => e.toJson()).toList(),
        'references': references.map((e) => e.toJson()).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
        'certifications': certifications.map((e) => e.toJson()).toList(),
        'projects': projects.map((e) => e.toJson()).toList(),
        'customSections': customSections.map((e) => e.toJson()).toList(),
        'sectionOrder': sectionOrder,
        'pageBreaks': pageBreaks,
        'baseFontSize': baseFontSize,
        'lineHeight': lineHeight,
        'primaryColorHex': primaryColorHex,
        'fontFamily': fontFamily,
        'pdfFileName': pdfFileName,
        'templateId': templateId,
        'id': id,
        'lastModified': lastModified?.toIso8601String(),
      };

  factory CVData.fromJson(Map<String, dynamic> json) => CVData(
        personalInfo: json['personalInfo'] != null ? PersonalInfo.fromJson(json['personalInfo']) : null,
        sectionTitles: json['sectionTitles'] != null ? SectionTitles.fromJson(json['sectionTitles']) : null,
        education: (json['education'] as List?)?.map((e) => Education.fromJson(e)).toList(),
        experience: (json['experience'] as List?)?.map((e) => Experience.fromJson(e)).toList(),
        internships: (json['internships'] as List?)?.map((e) => Internship.fromJson(e)).toList(),
        references: (json['references'] as List?)?.map((e) => Reference.fromJson(e)).toList(),
        skills: (json['skills'] as List?)?.map((e) => Skill.fromJson(e)).toList(),
        certifications: (json['certifications'] as List?)?.map((e) => Certification.fromJson(e)).toList(),
        projects: (json['projects'] as List?)?.map((e) => Project.fromJson(e)).toList(),
        customSections: (json['customSections'] as List?)?.map((e) => CustomSection.fromJson(e)).toList(),
        sectionOrder: (json['sectionOrder'] as List?)?.map((e) => e as String).toList(),
        pageBreaks: (json['pageBreaks'] as List?)?.map((e) => e as String).toList(),
        baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 10.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.0,
        primaryColorHex: json['primaryColorHex'] ?? '#0D47A1',
        fontFamily: json['fontFamily'] ?? 'Poppins',
        pdfFileName: json['pdfFileName'] ?? '',
        templateId: json['templateId'] ?? 'default',
        id: json['id'] ?? 'default_cv',
        lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      );

  CVData copyWith({
    PersonalInfo? personalInfo,
    SectionTitles? sectionTitles,
    List<Education>? education,
    List<Experience>? experience,
    List<Internship>? internships,
    List<Reference>? references,
    List<Skill>? skills,
    List<Certification>? certifications,
    List<Project>? projects,
    List<CustomSection>? customSections,
    List<String>? sectionOrder,
    List<String>? pageBreaks,
    double? baseFontSize,
    double? lineHeight,
    String? primaryColorHex,
    String? fontFamily,
    String? pdfFileName,
    String? templateId,
    String? id,
    DateTime? lastModified,
  }) {
    return CVData(
      personalInfo: personalInfo ?? this.personalInfo,
      sectionTitles: sectionTitles ?? this.sectionTitles,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      internships: internships ?? this.internships,
      references: references ?? this.references,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      projects: projects ?? this.projects,
      customSections: customSections ?? this.customSections,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      pageBreaks: pageBreaks ?? this.pageBreaks,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      fontFamily: fontFamily ?? this.fontFamily,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      templateId: templateId ?? this.templateId,
      id: id ?? this.id,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
