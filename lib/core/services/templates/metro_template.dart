import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class MetroTemplate implements CVTemplate {
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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36.0,
          marginBottom: 72.0, 
          marginLeft: CVTheme.pageMargin,
          marginRight: CVTheme.pageMargin,
        ),
        margin: pw.EdgeInsets.only(
          top: 36.0,
          bottom: 72.0, 
          left: CVTheme.pageMargin,
          right: CVTheme.pageMargin,
        ),
        build: (pw.Context context) {
          final sizes = TemplateUtils.calculateFontSizes(data.baseFontSize);
          final lh = data.lineHeight;
          final primaryColor = PdfColor.fromInt(int.parse(data.primaryColorHex.replaceFirst('#', '0xff')));
          
          final List<pw.Widget> content = [
            pw.SizedBox(height: 10), 
            _buildHeader(data.personalInfo, sizes, lh, primaryColor),
            pw.SizedBox(height: CVTheme.lineSpacing * lh),
          ];

          for (final sectionKey in data.sectionOrder) {
            if (sectionKey.startsWith('custom_')) {
              final customIndex = data.customSections.indexWhere((s) => s.id == sectionKey);
              if (customIndex != -1) {
                final custom = data.customSections[customIndex];
                if (custom.isVisible && custom.description.isNotEmpty) {
                  content.add(_buildSectionTitle(custom.title, sizes, lh, primaryColor));
                  content.addAll(TemplateUtils.buildRichText(custom.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
              }
              continue;
            }

            switch (sectionKey) {
              case 'personalInfo':
                if (data.sectionTitles.showPersonalInfo) {
                  content.add(_buildSectionTitle(data.sectionTitles.personalInfo, sizes, lh, primaryColor));
                  content.add(_buildContactInfo(data.personalInfo, sizes, lh, primaryColor));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'professionalSummary':
                if (data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.professionalSummary, sizes, lh, primaryColor));
                  content.addAll(TemplateUtils.buildRichText(data.personalInfo.profileSummary, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'experience':
                if (data.sectionTitles.showExperience && data.experience.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.experience, sizes, lh, primaryColor));
                  content.addAll(data.experience.map((e) => _buildExperienceItem(e, sizes, lh, regular, bold, italic, boldItalic)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'internships':
                if (data.sectionTitles.showInternships && data.internships.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.internships, sizes, lh, primaryColor));
                  content.addAll(data.internships.map((e) => _buildInternshipItem(e, sizes, lh, regular, bold, italic, boldItalic)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'education':
                if (data.sectionTitles.showEducation && data.education.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.education, sizes, lh, primaryColor));
                  content.addAll(data.education.map((e) => _buildEducationItem(e, sizes, lh, regular, bold, italic, boldItalic)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'skills':
                if (data.sectionTitles.showSkills && data.skills.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.skills, sizes, lh, primaryColor));
                  content.add(_buildSkillsList(data.skills, sizes['body'] ?? 10.0, lh));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'certifications':
                if (data.sectionTitles.showCertifications && data.certifications.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.certifications, sizes, lh, primaryColor));
                  content.addAll(data.certifications.map((c) => _buildCertificationItem(c, sizes, lh, regular, bold, italic, boldItalic)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'references':
                if (data.sectionTitles.showReferences && data.references.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.references, sizes, lh, primaryColor));
                  content.addAll(data.references.map((r) => _buildReferenceItem(r, sizes, lh, regular, bold, italic, boldItalic)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
            }
          }

          return content;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(PersonalInfo info, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    if (info.fields.isEmpty && info.jobTitle.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          info.showNameAsHeader ? info.fullName.toUpperCase() : 'CURRICULUM VITAE',
          style: pw.TextStyle(
            fontSize: (sizes['headerTitle'] ?? 20.0) + 4,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        if (info.jobTitle.isNotEmpty) ...[
          pw.SizedBox(height: 4 * lh),
          pw.Text(
            info.jobTitle.toUpperCase(),
            style: pw.TextStyle(
              fontSize: sizes['headerJobTitle'] ?? 14.0,
              color: PdfColors.grey800,
            ),
          ),
        ],
        pw.SizedBox(height: 12 * lh),
        pw.Container(
          height: 3, 
          width: double.infinity,
          color: primaryColor,
        ),
        pw.SizedBox(height: 12 * lh),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 12 * lh),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: primaryColor,
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: sizes['sectionTitle'] ?? 16.0,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildContactInfo(PersonalInfo info, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    List<CVField> infoFields = info.fields.where((f) => f.value.isNotEmpty).toList();
    if (info.showNameAsHeader) {
      infoFields = infoFields.where((f) => f.title != 'Name').toList();
    }
    if (infoFields.isEmpty) return pw.SizedBox();

    return pw.Wrap(
      spacing: 12,
      runSpacing: 4 * lh,
      children: infoFields.map((field) {
        return pw.Text(
          field.value, // In Metro, often just values are shown (no labels)
          style: pw.TextStyle(
            fontSize: sizes['body'] ?? 10.0,
            color: CVTheme.textColor,
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.position,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, 
                  fontStyle: pw.FontStyle.italic,
                  fontSize: sizes['itemTitle'] ?? 14.0,
                ),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey700, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                ),
              ),
            ],
          ),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(exp.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }

  pw.Widget _buildInternshipItem(Internship internship, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                internship.position,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, 
                  fontStyle: pw.FontStyle.italic,
                  fontSize: sizes['itemTitle'] ?? 14.0,
                ),
              ),
              pw.Text(
                '${internship.startDate} - ${internship.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey700, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                ),
              ),
            ],
          ),
          pw.Text(
            internship.company,
            style: pw.TextStyle(
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(internship.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education ed, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                ed.degree,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, 
                  fontStyle: pw.FontStyle.italic,
                  fontSize: sizes['itemTitle'] ?? 14.0,
                ),
              ),
              pw.Text(
                '${ed.startDate} - ${ed.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey700, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                ),
              ),
            ],
          ),
          pw.Text(
            ed.institution,
            style: pw.TextStyle(
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          if (ed.description.isNotEmpty) ...[
            pw.SizedBox(height: 4 * lh),
            ...TemplateUtils.buildRichText(ed.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
          ]
        ],
      ),
    );
  }

  pw.Widget _buildSkillsList(List<Skill> skills, double bodySize, double lh) {
    final skillNames = skills.map((s) => s.name).where((n) => n.isNotEmpty).toList();
    if (skillNames.isEmpty) return pw.SizedBox();

    return pw.Wrap(
      spacing: 8,
      runSpacing: 4 * lh,
      children: skillNames
          .map(
            (s) => pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: bodySize * 0.3,
                  height: bodySize * 0.3,
                  decoration: const pw.BoxDecoration(color: PdfColors.black, shape: pw.BoxShape.circle),
                ),
                pw.SizedBox(width: 4),
                pw.Text(s, style: pw.TextStyle(
                  fontSize: bodySize,
                  lineSpacing: bodySize * (lh - 1.0),
                )),
              ],
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildCertificationItem(Certification cert, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                cert.title + (!cert.isCompleted ? ' (In Progress)' : ''),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, 
                  fontStyle: pw.FontStyle.italic,
                  fontSize: sizes['itemTitle'] ?? 14.0,
                ),
              ),
              pw.Text(
                cert.date,
                style: pw.TextStyle(
                  color: PdfColors.grey700, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                ),
              ),
            ],
          ),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          if (cert.description.isNotEmpty) ...[
            pw.SizedBox(height: 4 * lh),
            ...TemplateUtils.buildRichText(cert.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
          ]
        ],
      ),
    );
  }

  pw.Widget _buildReferenceItem(Reference ref, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            ref.name,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, 
              fontStyle: pw.FontStyle.italic,
              fontSize: sizes['itemTitle'] ?? 14.0,
            ),
          ),
          pw.Text(
            '${ref.position} | ${ref.company}',
            style: pw.TextStyle(
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          pw.Row(
            children: [
              if (ref.email.isNotEmpty) 
                pw.Text(ref.email, style: pw.TextStyle(fontSize: sizes['body'] ?? 10.0)),
              if (ref.email.isNotEmpty && ref.phone.isNotEmpty)
                pw.Text(' | ', style: pw.TextStyle(fontSize: sizes['body'] ?? 10.0)),
              if (ref.phone.isNotEmpty)
                pw.Text(ref.phone, style: pw.TextStyle(fontSize: sizes['body'] ?? 10.0)),
            ],
          ),
        ],
      ),
    );
  }
}
