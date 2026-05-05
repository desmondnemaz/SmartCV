import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class ExecutiveTemplate implements CVTemplate {
  @override
  Future<Uint8List> generate(CVData data, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: italic,
        boldItalic: boldItalic,
      ),
    );

    final sizes = TemplateUtils.calculateFontSizes(data.baseFontSize);
    final lh = data.lineHeight;
    final primaryColor = PdfColor.fromInt(int.parse(data.primaryColorHex.replaceFirst('#', '0xff')));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(CVTheme.pageMargin),
        build: (pw.Context context) {
          final List<pw.Widget> content = [];

          // 1. Centered Header
          content.add(_buildHeader(data.personalInfo, sizes, lh, primaryColor));
          content.add(pw.SizedBox(height: 24 * lh));

          // 2. Sections based on Order
          for (final sectionKey in data.sectionOrder) {
            pw.Widget? sectionWidget;

            if (sectionKey == 'professionalSummary' && data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.professionalSummary,
                primaryColor,
                sizes,
                lh,
                TemplateUtils.buildRichText(data.personalInfo.profileSummary, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
              );
            } else if (sectionKey == 'experience' && data.sectionTitles.showExperience && data.experience.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.experience,
                primaryColor,
                sizes,
                lh,
                data.experience.map((e) => _buildExperienceItem(e, sizes, lh, regular, bold, italic, boldItalic)).toList(),
              );
            } else if (sectionKey == 'internships' && data.sectionTitles.showInternships && data.internships.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.internships,
                primaryColor,
                sizes,
                lh,
                data.internships.map((e) => _buildInternshipItem(e, sizes, lh, regular, bold, italic, boldItalic)).toList(),
              );
            } else if (sectionKey == 'education' && data.sectionTitles.showEducation && data.education.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.education,
                primaryColor,
                sizes,
                lh,
                data.education.map((e) => _buildEducationItem(e, sizes, lh, regular, bold, italic, boldItalic)).toList(),
              );
            } else if (sectionKey == 'skills' && data.sectionTitles.showSkills && data.skills.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.skills,
                primaryColor,
                sizes,
                lh,
                [_buildSkillsList(data.skills, sizes['body'] ?? 10.0, lh)],
              );
            } else if (sectionKey == 'certifications' && data.sectionTitles.showCertifications && data.certifications.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.certifications,
                primaryColor,
                sizes,
                lh,
                data.certifications.map((c) => _buildCertificationItem(c, sizes, lh, regular, bold, italic, boldItalic)).toList(),
              );
            } else if (sectionKey == 'references' && data.sectionTitles.showReferences && data.references.isNotEmpty) {
              sectionWidget = _buildSection(
                data.sectionTitles.references,
                primaryColor,
                sizes,
                lh,
                data.references.map((r) => _buildReferenceItem(r, sizes, lh, regular, bold, italic, boldItalic)).toList(),
              );
            } else if (sectionKey.startsWith('custom_')) {
              final customIndex = data.customSections.indexWhere((s) => s.id == sectionKey);
              if (customIndex != -1) {
                final custom = data.customSections[customIndex];
                if (custom.isVisible && custom.description.isNotEmpty) {
                  sectionWidget = _buildSection(
                    custom.title,
                    primaryColor,
                    sizes,
                    lh,
                    TemplateUtils.buildRichText(custom.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
                  );
                }
              }
            }

            if (sectionWidget != null) {
              content.add(sectionWidget);
              content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
            }
          }

          return content;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(PersonalInfo info, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    return pw.Column(
      children: [
        pw.Text(
          info.showNameAsHeader ? info.fullName.toUpperCase() : 'CURRICULUM VITAE',
          style: pw.TextStyle(
            fontSize: (sizes['headerTitle'] ?? 20.0) + 4,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        if (info.jobTitle.isNotEmpty) ...[
          pw.SizedBox(height: 4 * lh),
          pw.Text(
            info.jobTitle.toUpperCase(),
            style: pw.TextStyle(
              fontSize: sizes['headerJobTitle'] ?? 14.0,
              color: PdfColors.grey700,
              letterSpacing: 1.1,
            ),
          ),
        ],
        pw.SizedBox(height: 12 * lh),
        pw.Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: pw.WrapAlignment.center,
          children: info.fields
              .where((f) => f.value.isNotEmpty && (info.showNameAsHeader ? f.title != 'Name' : true))
              .map((f) => pw.Text(
                    f.value,
                    style: pw.TextStyle(
                      fontSize: sizes['fieldValue'] ?? 10.0,
                      color: PdfColors.grey800,
                    ),
                  ))
              .toList(),
        ),
        pw.SizedBox(height: 16 * lh),
        pw.Divider(thickness: 1.5, color: primaryColor),
      ],
    );
  }

  pw.Widget _buildSection(String title, PdfColor color, Map<String, double> sizes, double lh, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: sizes['sectionTitle'] ?? 16.0,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 8 * lh),
        ...children,
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      exp.position,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: sizes['itemTitle'] ?? 14.0,
                      ),
                    ),
                    pw.Text(
                      exp.company,
                      style: pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: sizes['itemText'] ?? 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6 * lh),
          ...TemplateUtils.buildRichText(exp.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }

  pw.Widget _buildInternshipItem(Internship internship, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      internship.position,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: sizes['itemTitle'] ?? 14.0,
                      ),
                    ),
                    pw.Text(
                      internship.company,
                      style: pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: sizes['itemText'] ?? 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Text(
                '${internship.startDate} - ${internship.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6 * lh),
          ...TemplateUtils.buildRichText(internship.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education ed, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  ed.degree,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: sizes['itemTitle'] ?? 14.0,
                  ),
                ),
                pw.Text(
                  ed.institution,
                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: sizes['itemText'] ?? 11.0,
                  ),
                ),
                if (ed.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4 * lh),
                  ...TemplateUtils.buildRichText(ed.description, regular, bold, italic, boldItalic, (sizes['body'] ?? 10.0) - 1, lh),
                ]
              ],
            ),
          ),
          pw.Text(
            '${ed.startDate} - ${ed.endDate}',
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: sizes['fieldLabel'] ?? 10.0,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSkillsList(List<Skill> skills, double bodySize, double lh) {
    final skillNames = skills.map((s) => s.name).where((n) => n.isNotEmpty).join(', ');
    if (skillNames.isEmpty) return pw.SizedBox();

    return pw.Text(
      skillNames,
      style: pw.TextStyle(fontSize: bodySize, color: PdfColors.grey900),
    );
  }

  pw.Widget _buildCertificationItem(Certification cert, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8 * lh),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              '${cert.title} - ${cert.issuer}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: sizes['itemText'] ?? 11.0,
              ),
            ),
          ),
          pw.Text(
            cert.date,
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: sizes['fieldLabel'] ?? 10.0,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReferenceItem(Reference ref, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${ref.name} - ${ref.position} at ${ref.company}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          pw.Text(
            '${ref.email} | ${ref.phone}',
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: (sizes['body'] ?? 10.0) - 1,
            ),
          ),
        ],
      ),
    );
  }
}
