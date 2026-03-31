class CVField {
  String title;
  String value;
  bool isCompulsory;

  CVField({
    required this.title,
    this.value = '',
    this.isCompulsory = false,
  });
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
          CVField(title: 'Full Name', isCompulsory: true),
          CVField(title: 'Email', isCompulsory: true),
          CVField(title: 'Phone', isCompulsory: true),
          CVField(title: 'Address', isCompulsory: true),
        ];

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
}

class Skill {
  String name;

  Skill({
    this.name = '',
  });
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
  });
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
  List<CustomSection> customSections;
  List<String> sectionOrder;
  double baseFontSize;
  double lineHeight;

  CVData({
    PersonalInfo? personalInfo,
    SectionTitles? sectionTitles,
    List<Education>? education,
    List<Experience>? experience,
    List<Internship>? internships,
    List<Reference>? references,
    List<Skill>? skills,
    List<Certification>? certifications,
    List<CustomSection>? customSections,
    List<String>? sectionOrder,
    this.baseFontSize = 10.0,
    this.lineHeight = 1.0,
  })  : personalInfo = personalInfo ?? PersonalInfo(),
        sectionTitles = sectionTitles ?? SectionTitles(),
        education = education ?? [],
        experience = experience ?? [],
        internships = internships ?? [],
        references = references ?? [],
        skills = skills ?? [],
        certifications = certifications ?? [],
        customSections = customSections ?? [],
        sectionOrder = sectionOrder ?? [
          'personalInfo',
          'professionalSummary',
          'experience',
          'internships',
          'education',
          'skills',
          'certifications',
          'references'
        ];
}
