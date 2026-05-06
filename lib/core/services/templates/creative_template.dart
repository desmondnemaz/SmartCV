import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class CreativeTemplate implements CVTemplate {
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
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          final leftColWidgets = <pw.Widget>[];
          final rightColWidgets = <pw.Widget>[];

          // --- HEADER (Full Width) ---
          final header = _buildHeader(data.personalInfo, sizes, lh, primaryColor);

          // --- MAIN CONTENT (LEFT) ---
          if (data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.professionalSummary, sizes, lh, primaryColor));
            leftColWidgets.addAll(TemplateUtils.buildRichText(data.personalInfo.profileSummary, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showExperience && data.experience.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.experience, sizes, lh, primaryColor));
            leftColWidgets.addAll(data.experience.map((e) => _buildExperienceItem(e, sizes, lh, regular, bold, italic, boldItalic)));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showEducation && data.education.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.education, sizes, lh, primaryColor));
            leftColWidgets.addAll(data.education.map((e) => _buildEducationItem(e, sizes, lh, regular, bold, italic, boldItalic)));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }
          if (data.sectionTitles.showProjects && data.projects.isNotEmpty) {
            leftColWidgets.add(_buildSectionTitle(data.sectionTitles.projects, sizes, lh, primaryColor));
            leftColWidgets.addAll(data.projects.map((p) => _buildProjectItem(p, sizes, lh, regular, bold, italic, boldItalic)));
            leftColWidgets.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
          }

          // --- SIDEBAR (RIGHT) ---
          if (data.sectionTitles.showPersonalInfo && data.personalInfo.fields.isNotEmpty) {
            rightColWidgets.add(_buildSidebarSectionTitle(data.sectionTitles.personalInfo, sizes, lh));
            rightColWidgets.add(_buildContactInfo(data.personalInfo, sizes, lh));
            rightColWidgets.add(pw.SizedBox(height: 20 * lh));
          }
          if (data.sectionTitles.showSkills && data.skills.isNotEmpty) {
            rightColWidgets.add(_buildSidebarSectionTitle(data.sectionTitles.skills, sizes, lh));
            rightColWidgets.add(_buildSkillsList(data.skills, sizes['body'] ?? 10.0, lh));
            rightColWidgets.add(pw.SizedBox(height: 20 * lh));
          }
          if (data.sectionTitles.showCertifications && data.certifications.isNotEmpty) {
            rightColWidgets.add(_buildSidebarSectionTitle(data.sectionTitles.certifications, sizes, lh));
            rightColWidgets.addAll(data.certifications.map((c) => _buildSidebarCertificationItem(c, sizes, lh)));
            rightColWidgets.add(pw.SizedBox(height: 20 * lh));
          }

          return [
            header,
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 0),
              child: pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(CVTheme.pageMargin),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: leftColWidgets,
                      ),
                    ),
                  ),
                  pw.Partition(
                    width: 180,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(24),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: rightColWidgets,
                      ),
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
    return pw.Container(
      color: primaryColor,
      padding: const pw.EdgeInsets.symmetric(horizontal: CVTheme.pageMargin, vertical: 48),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  info.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: (sizes['headerTitle'] ?? 20.0) + 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                if (info.jobTitle.isNotEmpty)
                  pw.Text(
                    info.jobTitle.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: sizes['headerJobTitle'] ?? 14.0,
                      color: PdfColors.white.withAlpha(0.9), // PdfColor alpha is 0.0 to 1.0
                      letterSpacing: 2,
                    ),
                  ),
              ],
            ),
          ),
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.white, width: 2),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                info.fullName.isNotEmpty ? info.fullName[0].toUpperCase() : 'CV',
                style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, Map<String, double> sizes, double lh, PdfColor color) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Row(
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: sizes['sectionTitle'] ?? 16.0,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(child: pw.Divider(color: color, thickness: 1)),
        ],
      ),
    );
  }

  pw.Widget _buildSidebarSectionTitle(String title, Map<String, double> sizes, double lh) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8 * lh),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: (sizes['sectionTitle'] ?? 16.0) - 2,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  pw.Widget _buildContactInfo(PersonalInfo info, Map<String, double> sizes, double lh) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: info.fields
          .where((f) => f.value.isNotEmpty && f.title != 'Name')
          .map((f) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(f.title, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
                    pw.Text(f.value, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  pw.Widget _buildExperienceItem(Experience exp, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 16 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(exp.position, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.Text('${exp.company} | ${exp.startDate} - ${exp.endDate}', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(exp.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education ed, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 12 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(ed.degree, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text(ed.institution, style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.Text('${ed.startDate} - ${ed.endDate}', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _buildSkillsList(List<Skill> skills, double bodySize, double lh) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skills.map((s) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.Container(width: 4, height: 4, decoration: const pw.BoxDecoration(color: PdfColors.grey600, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 6),
            pw.Text(s.name, style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildSidebarCertificationItem(Certification cert, Map<String, double> sizes, double lh) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(cert.title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(cert.issuer, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(Project project, Map<String, double> sizes, double lh, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 16 * lh),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(project.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          if (project.link.isNotEmpty)
            pw.Text(
              project.link,
              style: pw.TextStyle(
                color: PdfColors.blue700,
                fontSize: 9,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          pw.Text('${project.startDate} - ${project.endDate}', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 4 * lh),
          ...TemplateUtils.buildRichText(project.description, regular, bold, italic, boldItalic, sizes['body'] ?? 10.0, lh),
        ],
      ),
    );
  }
}
