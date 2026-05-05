import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class ModernTemplate implements CVTemplate {
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
        margin: const pw.EdgeInsets.all(0), // Zero margins so the header is full-bleed
        build: (pw.Context context) {
          
          final leftColWidgets = <pw.Widget>[];
          final rightColWidgets = <pw.Widget>[];

          // --- LEFT COLUMN CONTENT ---
          if (data.sectionTitles.showPersonalInfo && data.personalInfo.fields.isNotEmpty) {
            leftColWidgets.add(_buildContactInfo(data.personalInfo, data.sectionTitles.personalInfo, sizes, lh, primaryColor));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showSkills && data.skills.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.skills, sizes, lh, primaryColor));
            leftColWidgets.add(_buildSkillsList(data.skills, sizes['body'] ?? 10.0, lh));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showCertifications && data.certifications.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.certifications, sizes, lh, primaryColor));
            leftColWidgets.addAll(data.certifications.map((c) => _buildCertificationItem(c, sizes, lh, regular, bold, italic, boldItalic)));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showReferences && data.references.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.references, sizes, lh, primaryColor));
            leftColWidgets.addAll(data.references.map((r) => _buildReferenceItem(r, sizes, lh, regular, bold, italic, boldItalic)));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }

          // --- RIGHT COLUMN CONTENT ---
          if (data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
            rightColWidgets.add(_buildSectionTitle(data.sectionTitles.professionalSummary, sizes, lh, primaryColor));
            rightColWidgets.addAll(TemplateUtils.buildRichText(data.personalInfo.profileSummary, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh));
            rightColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showExperience && data.experience.isNotEmpty) {
            rightColWidgets.add(_buildSectionTitle(data.sectionTitles.experience, sizes, lh, primaryColor));
            rightColWidgets.addAll(data.experience.map((e) => _buildExperienceItem(e, sizes, lh, regular, bold, italic, boldItalic)));
            rightColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showInternships && data.internships.isNotEmpty) {
            rightColWidgets.add(_buildSectionTitle(data.sectionTitles.internships, sizes, lh, primaryColor));
            rightColWidgets.addAll(data.internships.map((e) => _buildInternshipItem(e, sizes, lh, regular, bold, italic, boldItalic)));
            rightColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showEducation && data.education.isNotEmpty) {
            rightColWidgets.add(_buildSectionTitle(data.sectionTitles.education, sizes, lh, primaryColor));
            rightColWidgets.addAll(data.education.map((e) => _buildEducationItem(e, sizes, lh, regular, bold, italic, boldItalic)));
            rightColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }

          // Add Custom Sections to right column
          for (final sectionKey in data.sectionOrder) {
            if (sectionKey.startsWith('custom_')) {
              final customIndex = data.customSections.indexWhere((s) => s.id == sectionKey);
              if (customIndex != -1) {
                final custom = data.customSections[customIndex];
                if (custom.isVisible && custom.description.isNotEmpty) {
                  rightColWidgets.add(_buildSectionTitle(custom.title, sizes, lh, primaryColor));
                  rightColWidgets.addAll(TemplateUtils.buildRichText(custom.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh));
                  rightColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
              }
            }
          }

          return [
            // 1. Full Bleed Header
            _buildHeader(data.personalInfo, sizes, lh, primaryColor),
            // 2. Partitions for Two-Column layout
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: CVTheme.pageMargin, vertical: 24),
              child: pw.Partitions(
                children: [
                  pw.Partition(
                    width: 170, // Left column width
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: leftColWidgets,
                      ),
                    ),
                  ),
                  pw.Partition(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: rightColWidgets,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(PersonalInfo info, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    if (info.fields.isEmpty && info.jobTitle.isEmpty) return pw.SizedBox();

    return pw.Container(
      color: primaryColor,
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(horizontal: CVTheme.pageMargin, vertical: 36),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            info.showNameAsHeader ? info.fullName.toUpperCase() : 'CURRICULUM VITAE',
            style: pw.TextStyle(
              fontSize: (sizes['headerTitle'] ?? 20.0) + 8, // Make name bigger in modern
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 2,
            ),
          ),
          if (info.jobTitle.isNotEmpty) ...[
            pw.SizedBox(height: 8 * lh),
            pw.Text(
              info.jobTitle.toUpperCase(),
              style: pw.TextStyle(
                fontSize: sizes['headerJobTitle'] ?? 14.0,
                color: PdfColors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: sizes['sectionTitle'] ?? 16.0,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            height: 2,
            width: 30, // Short modern underline
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildContactInfo(PersonalInfo info, String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    List<CVField> infoFields = info.fields.where((f) => f.value.isNotEmpty).toList();
    if (info.showNameAsHeader) {
      infoFields = infoFields.where((f) => f.title != 'Name').toList();
    }
    if (infoFields.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, sizes, lh, primaryColor),
        ...infoFields.map((field) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 8 * lh),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  field.title.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, 
                    fontSize: (sizes['fieldLabel'] ?? 10.0) - 1,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  field.value,
                  style: pw.TextStyle(
                    fontSize: sizes['fieldValue'] ?? 10.0,
                    color: CVTheme.textColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
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
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.company,
                style: pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: sizes['itemText'] ?? 11.0,
                ),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey500, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
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
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
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
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                internship.company,
                style: pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: sizes['itemText'] ?? 11.0,
                ),
              ),
              pw.Text(
                '${internship.startDate} - ${internship.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey500, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
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
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
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
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                ed.institution,
                style: pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: sizes['itemText'] ?? 11.0,
                ),
              ),
              pw.Text(
                '${ed.startDate} - ${ed.endDate}',
                style: pw.TextStyle(
                  color: PdfColors.grey500, 
                  fontSize: sizes['fieldLabel'] ?? 10.0,
                ),
              ),
            ],
          ),
          if (ed.description.isNotEmpty) ...[
            pw.SizedBox(height: 6 * lh),
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
      spacing: 6,
      runSpacing: 6,
      children: skillNames.map((s) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          s, 
          style: pw.TextStyle(fontSize: bodySize - 1, color: PdfColors.grey800)
        ),
      )).toList(),
    );
  }

  pw.Widget _buildCertificationItem(Certification cert, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: CVTheme.itemSpacing * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cert.title + (!cert.isCompleted ? ' (In Progress)' : ''),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, 
              fontSize: sizes['itemTitle'] ?? 14.0,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${cert.issuer} | ${cert.date}',
            style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: sizes['fieldLabel'] ?? 10.0,
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
              fontSize: sizes['itemTitle'] ?? 14.0,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '${ref.position} | ${ref.company}',
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: sizes['itemText'] ?? 11.0,
            ),
          ),
          pw.SizedBox(height: 2),
          if (ref.email.isNotEmpty) 
            pw.Text(ref.email, style: pw.TextStyle(fontSize: sizes['body'] ?? 10.0, color: PdfColors.grey600)),
          if (ref.phone.isNotEmpty)
            pw.Text(ref.phone, style: pw.TextStyle(fontSize: sizes['body'] ?? 10.0, color: PdfColors.grey600)),
        ],
      ),
    );
  }
}
