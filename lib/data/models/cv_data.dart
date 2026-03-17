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

  PersonalInfo({
    this.jobTitle = '',
    this.headerAlignment = 'left',
    List<CVField>? fields,
    this.profileSummary = '',
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

class Skill {
  String name;

  Skill({
    this.name = '',
  });
}

class CVData {
  PersonalInfo personalInfo;
  List<Education> education;
  List<Experience> experience;
  List<Skill> skills;

  CVData({
    PersonalInfo? personalInfo,
    List<Education>? education,
    List<Experience>? experience,
    List<Skill>? skills,
  })  : personalInfo = personalInfo ?? PersonalInfo(),
        education = education ?? [],
        experience = experience ?? [],
        skills = skills ?? [];
}
