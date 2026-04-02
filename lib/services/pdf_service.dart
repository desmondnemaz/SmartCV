import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/cv_data.dart';
import '../core/theme/cv_theme.dart';

class PDFService {
  static String? _currentFontFamily;
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;
  static pw.Font? _fontItalic;
  static pw.Font? _fontBoldItalic;

  static Future<pw.Font> _loadFontSafe(Future<pw.Font> Function() onlineProvider, String? assetPath) async {
    try {
      return await onlineProvider();
    } catch (_) {
      if (assetPath != null) {
        try {
          final data = await rootBundle.load(assetPath);
          return pw.Font.ttf(data);
        } catch (e) {
          final fallback = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
          return pw.Font.ttf(fallback);
        }
      }
      final fallback = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      return pw.Font.ttf(fallback);
    }
  }

  static Future<void> _loadFonts(String fontFamily) async {
    if (_currentFontFamily == fontFamily && _fontRegular != null) return;
    _currentFontFamily = fontFamily;

    switch (fontFamily) {
      case 'Arimo':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.arimoRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.arimoBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.arimoItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.arimoBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'Carlito':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.carlitoRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.carlitoBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.carlitoItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.carlitoBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'Courier Prime':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.courierPrimeRegular, null);
        _fontBold = await _loadFontSafe(PdfGoogleFonts.courierPrimeBold, null);
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.courierPrimeItalic, null);
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.courierPrimeBoldItalic, null);
        break;
      case 'Open Sans':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.openSansRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.openSansBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.openSansItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.openSansBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'EB Garamond':
      case 'Noto Serif': // Use same logic for Garamond/Serif
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.notoSerifRegular, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.notoSerifBold, 'assets/fonts/EBGaramond-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifItalic, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifBoldItalic, 'assets/fonts/EBGaramond-Bold.ttf');
        break;
      case 'Gelasio':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.gelasioRegular, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.gelasioBold, 'assets/fonts/EBGaramond-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.gelasioItalic, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.gelasioBoldItalic, 'assets/fonts/EBGaramond-Bold.ttf');
        break;
      case 'Lato':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.latoRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.latoBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.latoItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.latoBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'Noto Sans':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.notoSansRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.notoSansBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.notoSansItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.notoSansBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'Poppins':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.poppinsRegular, 'assets/fonts/Poppins-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.poppinsBold, 'assets/fonts/Poppins-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.poppinsItalic, 'assets/fonts/Poppins-Regular.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.poppinsBoldItalic, 'assets/fonts/Poppins-Bold.ttf');
        break;
      case 'Tinos':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.tinosRegular, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.tinosBold, 'assets/fonts/EBGaramond-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.tinosItalic, 'assets/fonts/EBGaramond-Regular.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.tinosBoldItalic, 'assets/fonts/EBGaramond-Bold.ttf');
        break;
      case 'Source Sans 3':
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.sourceSans3Regular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.sourceSans3Bold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.sourceSans3Italic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.sourceSans3BoldItalic, 'assets/fonts/Roboto-Bold.ttf');
        break;
      case 'Roboto':
      default:
        _fontRegular = await _loadFontSafe(PdfGoogleFonts.robotoRegular, 'assets/fonts/Roboto-Regular.ttf');
        _fontBold = await _loadFontSafe(PdfGoogleFonts.robotoBold, 'assets/fonts/Roboto-Bold.ttf');
        _fontItalic = await _loadFontSafe(PdfGoogleFonts.robotoItalic, 'assets/fonts/Roboto-Italic.ttf');
        _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.robotoBoldItalic, 'assets/fonts/Roboto-Bold.ttf');
    }
  }

  static Map<String, double> _calculateFontSizes(double x) {
    return {
      'body': x,
      'sectionTitle': x + 2,
      'headerTitle': x * 2,
      'headerJobTitle': x + 2,
      'itemTitle': x + 2,
      'itemText': x + 1,
      'fieldLabel': x - 1,
      'fieldValue': x - 1,
    };
  }

  static Future<Uint8List> generateCV(CVData data) async {
    await _loadFonts(data.fontFamily);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _fontRegular!,
        bold: _fontBold!,
        italic: _fontItalic!,
        boldItalic: _fontBoldItalic!,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(CVTheme.pageMargin),
        build: (pw.Context context) {
          final sizes = _calculateFontSizes(data.baseFontSize);
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
                  // Render rich text (Quill Delta JSON) to PDF
                  content.addAll(_buildRichText(custom.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh));
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
                  content.addAll(_buildRichText(data.personalInfo.profileSummary, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'experience':
                if (data.sectionTitles.showExperience && data.experience.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.experience, sizes, lh, primaryColor));
                  content.addAll(data.experience.map((e) => _buildExperienceItem(e, sizes, lh)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'internships':
                if (data.sectionTitles.showInternships && data.internships.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.internships, sizes, lh, primaryColor));
                  content.addAll(data.internships.map((e) => _buildInternshipItem(e, sizes, lh)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'education':
                if (data.sectionTitles.showEducation && data.education.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.education, sizes, lh, primaryColor));
                  content.addAll(data.education.map((e) => _buildEducationItem(e, sizes, lh)));
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
                  content.addAll(data.certifications.map((c) => _buildCertificationItem(c, sizes, lh)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing * lh));
                }
                break;
              case 'references':
                if (data.sectionTitles.showReferences && data.references.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.references, sizes, lh, primaryColor));
                  content.addAll(data.references.map((r) => _buildReferenceItem(r, sizes, lh)));
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

  static pw.Widget _buildHeader(PersonalInfo info, Map<String, double> sizes, double lh, PdfColor primaryColor) {
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

  static pw.Widget _buildContactInfo(PersonalInfo info, String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
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

  static pw.Widget _buildSectionTitle(String title, Map<String, double> sizes, double lh, PdfColor primaryColor) {
    return pw.Column(
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
    );
  }

  static pw.Widget _buildExperienceItem(Experience exp, Map<String, double> sizes, double lh) {
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
          ..._buildRichText(exp.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh),
        ],
      ),
    );
  }

  static pw.Widget _buildInternshipItem(Internship internship, Map<String, double> sizes, double lh) {
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
          ..._buildRichText(internship.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education ed, Map<String, double> sizes, double lh) {
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
            ..._buildRichText(ed.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh),
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildSkillsList(List<Skill> skills, double bodySize, double lh) {
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

  static pw.Widget _buildCertificationItem(Certification cert, Map<String, double> sizes, double lh) {
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
            ..._buildRichText(cert.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!, sizes['body']!, lh),
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildReferenceItem(Reference ref, Map<String, double> sizes, double lh) {
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

  /// Parses and renders rich text from Quill Delta JSON to PDF widgets.
  /// Supports bold, italic, underline, list bullets, numbering, and alignment.
  static List<pw.Widget> _buildRichText(String jsonString, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic, double bodySize, double lh) {
    try {
      final List<dynamic> delta = jsonDecode(jsonString);
      final List<pw.Widget> widgets = [];
      List<pw.InlineSpan> currentSpans = [];
      pw.TextAlign alignment = pw.TextAlign.left;
      bool isBullet = false;
      bool isOrdered = false;
      int listIndex = 1; // Counter for ordered lists

      // Group ops by line to handle alignment and lists correctly
      for (final op in delta) {
        if (op is! Map || !op.containsKey('insert')) continue;

        final insert = op['insert'];
        final attributes = op['attributes'] as Map<String, dynamic>?;

        if (insert is String) {
          // If insert contains a newline, it marks the end of a line or a paragraph style change
          if (insert.contains('\n')) {
            final parts = insert.split('\n');
            
            for (int i = 0; i < parts.length; i++) {
              if (parts[i].isNotEmpty) {
                // Add remaining text before the newline
                currentSpans.add(_buildSpan(parts[i], attributes, regular, bold, italic, boldItalic, bodySize, lh));
              }

              // The newline itself often carries attributes for the whole line in Quill (like list or header)
              if (i < parts.length - 1) {
                // Determine line attributes
                if (attributes != null) {
                  if (attributes['list'] == 'bullet') {
                    isBullet = true;
                    isOrdered = false;
                  } else if (attributes['list'] == 'ordered') {
                    isOrdered = true;
                    isBullet = false;
                  } else {
                    isBullet = false;
                    isOrdered = false;
                    listIndex = 1; // Reset if list ends
                  }

                  final align = attributes['align'];
                  if (align == 'center') {
                    alignment = pw.TextAlign.center;
                  } else if (align == 'right') {
                    alignment = pw.TextAlign.right;
                  } else if (align == 'justify') {
                    alignment = pw.TextAlign.justify;
                  }
                } else {
                  // No attributes means the list ends here
                  isBullet = false;
                  isOrdered = false;
                  listIndex = 1;
                }

                // Build the line widget
                if (currentSpans.isNotEmpty || isBullet || isOrdered) {
                  final richText = pw.RichText(
                    text: pw.TextSpan(children: currentSpans),
                    textAlign: alignment,
                  );

                  if (isBullet || isOrdered) {
                    final prefix = isBullet ? '•' : '$listIndex.';
                    if (isOrdered) {
                      listIndex++;
                    }
                    
                    widgets.add(pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.only(right: 8, top: 2 * lh),
                          child: pw.Text(prefix, style: pw.TextStyle(
                            fontSize: bodySize, 
                            font: regular,
                            lineSpacing: bodySize * (lh - 1.0),
                          )),
                        ),
                        pw.Expanded(child: richText),
                      ],
                    ));
                  } else {
                    widgets.add(richText);
                  }
                } else if (widgets.isNotEmpty) {
                  // Empty line (extra newline)
                  widgets.add(pw.SizedBox(height: 4 * lh));
                }

                // Reset line state
                currentSpans = [];
                isBullet = false;
                isOrdered = false;
                alignment = pw.TextAlign.left;
              }
            }
          } else {
            // Normal text without newline
            currentSpans.add(_buildSpan(insert, attributes, regular, bold, italic, boldItalic, bodySize, lh));
          }
        }
      }

      // Add any leftover spans
      if (currentSpans.isNotEmpty) {
        widgets.add(pw.RichText(text: pw.TextSpan(children: currentSpans), textAlign: alignment));
      }

      return widgets.isEmpty ? [pw.SizedBox()] : widgets;
    } catch (e) {
      // Fallback for plain text if JSON parsing fails
      return [
        pw.Text(jsonString, 
          style: pw.TextStyle(
            fontSize: bodySize, 
            font: regular,
            lineSpacing: bodySize * (lh - 1.0),
          ),
          textAlign: pw.TextAlign.left)
      ];
    }
  }

  /// Creates a pw.TextSpan with appropriate styles for a snippet of text.
  static pw.InlineSpan _buildSpan(String text, Map<String, dynamic>? attr, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic, double bodySize, double lh) {
    final isBold = attr?['bold'] == true;
    final isItalic = attr?['italic'] == true;
    final isUnderline = attr?['underline'] == true;

    pw.Font selectedFont = regular;
    if (isBold && isItalic) {
      selectedFont = boldItalic;
    } else if (isBold) {
      selectedFont = bold;
    } else if (isItalic) {
      selectedFont = italic;
    }

    return pw.TextSpan(
      text: text,
      style: pw.TextStyle(
        fontSize: bodySize,
        font: selectedFont,
        decoration: isUnderline ? pw.TextDecoration.underline : null,
        lineSpacing: bodySize * (lh - 1.0),
      ),
    );
  }
}
