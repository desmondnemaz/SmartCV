import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/cv_data.dart';
import '../core/theme/cv_theme.dart';

class PDFService {
  static Future<Uint8List> generateCV(CVData data) async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(CVTheme.pageMargin),
        build: (pw.Context context) {
          return [
            _buildHeader(data.personalInfo),
            pw.SizedBox(height: CVTheme.lineSpacing),
            _buildContactInfo(data.personalInfo),
            pw.SizedBox(height: CVTheme.sectionSpacing),
            if (data.personalInfo.profileSummary.isNotEmpty) ...[
              _buildSectionTitle('Professional Summary'),
              pw.Text(data.personalInfo.profileSummary, 
                style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize),
                textAlign: pw.TextAlign.left),
              pw.SizedBox(height: CVTheme.sectionSpacing),
            ],
            if (data.experience.isNotEmpty) ...[
              _buildSectionTitle('Experience'),
              ...data.experience.map((e) => _buildExperienceItem(e)),
              pw.SizedBox(height: CVTheme.sectionSpacing),
            ],
            if (data.education.isNotEmpty) ...[
              _buildSectionTitle('Education'),
              ...data.education.map((e) => _buildEducationItem(e)),
              pw.SizedBox(height: CVTheme.sectionSpacing),
            ],
            if (data.skills.isNotEmpty) ...[
              _buildSectionTitle('Skills'),
              _buildSkillsList(data.skills),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(PersonalInfo info) {
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
                'CURRICULUM VITAE',
                style: pw.TextStyle(
                  fontSize: CVTheme.headerTitleSize,
                  fontWeight: pw.FontWeight.bold,
                  color: CVTheme.primaryColor,
                  letterSpacing: 2,
                ),
              ),
              if (info.jobTitle.isNotEmpty) ...[
                pw.SizedBox(height: CVTheme.headerTitleBottomSpacing),
                pw.Text(
                  info.jobTitle.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: CVTheme.headerJobTitleSize,
                    fontWeight: pw.FontWeight.bold,
                    color: CVTheme.secondaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: CVTheme.headerAfterDividerSpacing),
        pw.Divider(color: CVTheme.primaryColor, thickness: CVTheme.headerDividerThickness),
      ],
    );
  }

  static pw.Widget _buildContactInfo(PersonalInfo info) {
    final infoFields = info.fields.where((f) => f.value.isNotEmpty).toList();
    if (infoFields.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        ...infoFields.map((field) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: CVTheme.fieldPaddingBottom),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: CVTheme.labelColumnWidth,
                  child: pw.Text(
                    field.title,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, 
                      fontSize: CVTheme.fieldLabelSize,
                      color: CVTheme.textColor,
                    ),
                  ),
                ),
                pw.SizedBox(width: CVTheme.labelValueGap),
                pw.Expanded(
                  child: pw.Text(
                    field.value,
                    style: const pw.TextStyle(
                      fontSize: CVTheme.fieldValueSize,
                      color: CVTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: CVTheme.sectionTitleSize,
            fontWeight: pw.FontWeight.bold,
            color: CVTheme.accentColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: CVTheme.dividerColor, thickness: CVTheme.sectionDividerThickness),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: CVTheme.itemSpacing),
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
                  fontSize: CVTheme.itemTitleSize,
                ),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: const pw.TextStyle(color: CVTheme.lightTextColor, fontSize: 10),
              ),
            ],
          ),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(exp.description, style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education ed) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: CVTheme.itemSpacing),
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
                  fontSize: CVTheme.itemTitleSize,
                ),
              ),
              pw.Text(
                '${ed.startDate} - ${ed.endDate}',
                style: const pw.TextStyle(color: CVTheme.lightTextColor, fontSize: 10),
              ),
            ],
          ),
          pw.Text(
            ed.institution,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: 11,
            ),
          ),
          if (ed.description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(ed.description, style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildSkillsList(List<Skill> skills) {
    final skillNames = skills.map((s) => s.name).where((n) => n.isNotEmpty).toList();
    if (skillNames.isEmpty) return pw.SizedBox();

    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skillNames
          .map(
            (s) => pw.Text('• $s', style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
          )
          .toList(),
    );
  }
}
