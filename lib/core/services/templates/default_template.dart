import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class DefaultTemplate implements CVTemplate {
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
          marginBottom: 72.0, // 1 inch
          marginLeft: CVTheme.pageMargin,
          marginRight: CVTheme.pageMargin,
        ),
        margin: pw.EdgeInsets.only(
          top: 36.0,
          bottom: 72.0, // 1 inch
          left: CVTheme.pageMargin,
          right: CVTheme.pageMargin,
        ),
        build: (pw.Context context) {
          final sizes = TemplateUtils.calculateFontSizes(data.baseFontSize);
          final lh = data.lineHeight;
          final primaryColor = PdfColor.fromInt(int.parse(data.primaryColorHex.replaceFirst('#', '0xff')));
          
          final List<pw.Widget> content = [
            pw.SizedBox(height: 10), // Additional top safe area for mobile printing
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
                  content.addAll(TemplateUtils.buildRichText(custom.description, regular, bold, italic, boldItalic, sizes['body']!, lh));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
              }
              continue;
            }

            switch (sectionKey) {
              case 'personalInfo':
                if (data.sectionTitles.showPersonalInfo) {
                  content.add(_buildContactInfo(data.personalInfo, data.sectionTitles.personalInfo, sizes, lh, primaryColor));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'professionalSummary':
                if (data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.professionalSummary, sizes, lh, primaryColor));
                  content.addAll(TemplateUtils.buildRichText(data.personalInfo.profileSummary, regular, bold, italic, boldItalic, sizes['body']!, lh));
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
                  content.add(_buildSkillsList(data.skills, sizes['body']!, lh));
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

    pw.CrossAxisAlignment titleAlign;
    switch (info.headerAlignment) {
      case 'center':
        titleAlign = pw.CrossAxisAlignment.center;
        break;
      case 'right':
        titleAlign = pw.CrossAxisAlignment.end;
        break;
      case 'left':
      default:
        titleAlign = pw.CrossAxisAlignment.start;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: titleAlign,
            children: [
              pw.Text(
                info.showNameAsHeader ? info.fullName.toUpperCase() : 'CURRICULUM VITAE',
                style: pw.TextStyle(
                  fontSize: sizes['headerTitle'],
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2,
                  lineSpacing: sizes['headerTitle']! * (lh - 1.0),
                ),
              ),
              if (info.jobTitle.isNotEmpty) ...[
                pw.SizedBox(height: CVTheme.headerTitleBottomSpacing * lh),
                pw.Text(
                  info.jobTitle.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: sizes['headerJobTitle'],
                    color: primaryColor,
                    lineSpacing: sizes['headerJobTitle']! * (lh - 1.0),
                  ),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: CVTheme.headerAfterDividerSpacing * lh),
        pw.Divider(color: primaryColor, thickness: CVTheme.headerDividerThickness),
      ],
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
            padding: pw.EdgeInsets.only(bottom: CVTheme.fieldPaddingBottom * lh),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: CVTheme.labelColumnWidth,
                  child: pw.Text(
                    field.title,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, 
                      fontSize: sizes['fieldLabel'],
                      color: CVTheme.textColor,
                      lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                    ),
                  ),
                ),
                pw.SizedBox(width: CVTheme.labelValueGap),
                pw.Expanded(
                  child: pw.Text(
                    field.value,
                    style: pw.TextStyle(
                      fontSize: sizes['fieldValue'],
                      color: CVTheme.textColor,
                      lineSpacing: sizes['fieldValue']! * (lh - 1.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: sizes['sectionTitle'],
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
              lineSpacing: sizes['sectionTitle']! * (lh - 1.0),
            ),
          ),
          pw.SizedBox(height: 1 * lh),
          pw.Divider(color: CVTheme.dividerColor, thickness: CVTheme.sectionDividerThickness),
          pw.SizedBox(height: 2 * lh),
        ],
      ),
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
                  fontSize: sizes['itemTitle'],
                  lineSpacing: sizes['itemTitle']! * (lh - 1.0),
                ),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: pw.TextStyle(
                  color: CVTheme.lightTextColor, 
                  fontSize: sizes['fieldLabel'],
                  lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                ),
              ),
            ],
          ),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: sizes['itemText'],
              lineSpacing: sizes['itemText']! * (lh - 1.0),
            ),
          ),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(exp.description, regular, bold, italic, boldItalic, sizes['body']!, lh),
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
                  fontSize: sizes['itemTitle'],
                  lineSpacing: sizes['itemTitle']! * (lh - 1.0),
                ),
              ),
              pw.Text(
                '${internship.startDate} - ${internship.endDate}',
                style: pw.TextStyle(
                  color: CVTheme.lightTextColor, 
                  fontSize: sizes['fieldLabel'],
                  lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                ),
              ),
            ],
          ),
          pw.Text(
            internship.company,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: sizes['itemText'],
              lineSpacing: sizes['itemText']! * (lh - 1.0),
            ),
          ),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(internship.description, regular, bold, italic, boldItalic, sizes['body']!, lh),
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
                  fontSize: sizes['itemTitle'],
                  lineSpacing: sizes['itemTitle']! * (lh - 1.0),
                ),
              ),
              pw.Text(
                '${ed.startDate} - ${ed.endDate}',
                style: pw.TextStyle(
                  color: CVTheme.lightTextColor, 
                  fontSize: sizes['fieldLabel'],
                  lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                ),
              ),
            ],
          ),
          pw.Text(
            ed.institution,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: sizes['itemText'],
              lineSpacing: sizes['itemText']! * (lh - 1.0),
            ),
          ),
          if (ed.description.isNotEmpty) ...[
            pw.SizedBox(height: 4 * lh),
            ...TemplateUtils.buildRichText(ed.description, regular, bold, italic, boldItalic, sizes['body']!, lh),
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
            (s) => pw.Text('• $s', style: pw.TextStyle(
              fontSize: bodySize,
              lineSpacing: bodySize * (lh - 1.0),
            )),
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
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: cert.title,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, 
                          fontSize: sizes['itemTitle'],
                          lineSpacing: sizes['itemTitle']! * (lh - 1.0),
                        ),
                      ),
                      if (!cert.isCompleted)
                        pw.TextSpan(
                          text: ' (In Progress)',
                          style: pw.TextStyle(
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.orange800,
                            fontSize: sizes['fieldLabel'],
                            lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.Text(
                cert.date,
                style: pw.TextStyle(
                  color: CVTheme.lightTextColor, 
                  fontSize: sizes['fieldLabel'],
                  lineSpacing: sizes['fieldLabel']! * (lh - 1.0),
                ),
              ),
            ],
          ),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: sizes['itemText'],
              lineSpacing: sizes['itemText']! * (lh - 1.0),
            ),
          ),
          if (cert.description.isNotEmpty) ...[
            pw.SizedBox(height: 4 * lh),
            ...TemplateUtils.buildRichText(cert.description, regular, bold, italic, boldItalic, sizes['body']!, lh),
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
              fontSize: sizes['itemTitle'],
              lineSpacing: sizes['itemTitle']! * (lh - 1.0),
            ),
          ),
          pw.Text(
            '${ref.position} | ${ref.company}',
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: sizes['itemText'],
              lineSpacing: sizes['itemText']! * (lh - 1.0),
            ),
          ),
          pw.Row(
            children: [
              if (ref.email.isNotEmpty) 
                pw.Text('Email: ${ref.email}', style: pw.TextStyle(
                  fontSize: sizes['body'],
                  lineSpacing: sizes['body']! * (lh - 1.0),
                )),
              if (ref.email.isNotEmpty && ref.phone.isNotEmpty)
                pw.Text(' | ', style: pw.TextStyle(
                  fontSize: sizes['body'],
                  lineSpacing: sizes['body']! * (lh - 1.0),
                )),
              if (ref.phone.isNotEmpty)
                pw.Text('Phone: ${ref.phone}', style: pw.TextStyle(
                  fontSize: sizes['body'],
                  lineSpacing: sizes['body']! * (lh - 1.0),
                )),
            ],
          ),
        ],
      ),
    );
  }
}
