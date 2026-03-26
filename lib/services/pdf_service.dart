import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/cv_data.dart';
import '../core/theme/cv_theme.dart';

class PDFService {
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;
  static pw.Font? _fontItalic;
  static pw.Font? _fontBoldItalic;

  static Future<void> _loadFonts() async {
    _fontRegular ??= await PdfGoogleFonts.robotoRegular();
    _fontBold ??= await PdfGoogleFonts.robotoBold();
    _fontItalic ??= await PdfGoogleFonts.robotoItalic();
    _fontBoldItalic ??= await PdfGoogleFonts.robotoBoldItalic();
  }

  static Future<Uint8List> generateCV(CVData data) async {
    await _loadFonts();

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
          final List<pw.Widget> content = [
            _buildHeader(data.personalInfo),
            pw.SizedBox(height: CVTheme.lineSpacing),
          ];

          for (final sectionKey in data.sectionOrder) {
            if (sectionKey.startsWith('custom_')) {
              final customIndex = data.customSections.indexWhere((s) => s.id == sectionKey);
              if (customIndex != -1) {
                final custom = data.customSections[customIndex];
                if (custom.isVisible && custom.description.isNotEmpty) {
                  content.add(_buildSectionTitle(custom.title));
                  // Render rich text (Quill Delta JSON) to PDF
                  content.addAll(_buildRichText(custom.description, _fontRegular!, _fontBold!, _fontItalic!, _fontBoldItalic!));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
              }
              continue;
            }

            switch (sectionKey) {
              case 'personalInfo':
                if (data.sectionTitles.showPersonalInfo) {
                  content.add(_buildContactInfo(data.personalInfo, data.sectionTitles.personalInfo));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'professionalSummary':
                if (data.sectionTitles.showProfessionalSummary && data.personalInfo.profileSummary.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.professionalSummary));
                  content.add(pw.Text(data.personalInfo.profileSummary, 
                    style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize),
                    textAlign: pw.TextAlign.left));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'experience':
                if (data.sectionTitles.showExperience && data.experience.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.experience));
                  content.addAll(data.experience.map((e) => _buildExperienceItem(e)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'internships':
                if (data.sectionTitles.showInternships && data.internships.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.internships));
                  content.addAll(data.internships.map((e) => _buildInternshipItem(e)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'education':
                if (data.sectionTitles.showEducation && data.education.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.education));
                  content.addAll(data.education.map((e) => _buildEducationItem(e)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'skills':
                if (data.sectionTitles.showSkills && data.skills.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.skills));
                  content.add(_buildSkillsList(data.skills));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'certifications':
                if (data.sectionTitles.showCertifications && data.certifications.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.certifications));
                  content.addAll(data.certifications.map((c) => _buildCertificationItem(c)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
                }
                break;
              case 'references':
                if (data.sectionTitles.showReferences && data.references.isNotEmpty) {
                  content.add(_buildSectionTitle(data.sectionTitles.references));
                  content.addAll(data.references.map((r) => _buildReferenceItem(r)));
                  content.add(pw.SizedBox(height: CVTheme.sectionSpacing));
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

  static pw.Widget _buildContactInfo(PersonalInfo info, String title) {
    final infoFields = info.fields.where((f) => f.value.isNotEmpty).toList();
    if (infoFields.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
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
        }),
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

  static pw.Widget _buildInternshipItem(Internship internship) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: CVTheme.itemSpacing),
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
                  fontSize: CVTheme.itemTitleSize,
                ),
              ),
              pw.Text(
                '${internship.startDate} - ${internship.endDate}',
                style: const pw.TextStyle(color: CVTheme.lightTextColor, fontSize: 10),
              ),
            ],
          ),
          pw.Text(
            internship.company,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(internship.description, style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
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

  static pw.Widget _buildCertificationItem(Certification cert) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: CVTheme.itemSpacing),
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
                          fontSize: CVTheme.itemTitleSize,
                        ),
                      ),
                      if (!cert.isCompleted)
                        pw.TextSpan(
                          text: ' (In Progress)',
                          style: pw.TextStyle(
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.orange800,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.Text(
                cert.date,
                style: const pw.TextStyle(color: CVTheme.lightTextColor, fontSize: 10),
              ),
            ],
          ),
          pw.Text(
            cert.issuer,
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: 11,
            ),
          ),
          if (cert.description.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(cert.description, style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildReferenceItem(Reference ref) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: CVTheme.itemSpacing),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            ref.name,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, 
              fontSize: CVTheme.itemTitleSize,
            ),
          ),
          pw.Text(
            '${ref.position} | ${ref.company}',
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: CVTheme.secondaryColor,
              fontSize: 11,
            ),
          ),
          pw.Row(
            children: [
              if (ref.email.isNotEmpty) 
                pw.Text('Email: ${ref.email}', style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
              if (ref.email.isNotEmpty && ref.phone.isNotEmpty)
                pw.Text(' | ', style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
              if (ref.phone.isNotEmpty)
                pw.Text('Phone: ${ref.phone}', style: const pw.TextStyle(fontSize: CVTheme.bodyFontSize)),
            ],
          ),
        ],
      ),
    );
  }

  /// Parses and renders rich text from Quill Delta JSON to PDF widgets.
  /// Supports bold, italic, underline, list bullets, numbering, and alignment.
  static List<pw.Widget> _buildRichText(String jsonString, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
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
                currentSpans.add(_buildSpan(parts[i], attributes, regular, bold, italic, boldItalic));
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
                          padding: const pw.EdgeInsets.only(right: 8, top: 2),
                          child: pw.Text(prefix, style: pw.TextStyle(fontSize: CVTheme.bodyFontSize, font: regular)),
                        ),
                        pw.Expanded(child: richText),
                      ],
                    ));
                  } else {
                    widgets.add(richText);
                  }
                } else if (widgets.isNotEmpty) {
                  // Empty line (extra newline)
                  widgets.add(pw.SizedBox(height: 4));
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
            currentSpans.add(_buildSpan(insert, attributes, regular, bold, italic, boldItalic));
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
          style: pw.TextStyle(fontSize: CVTheme.bodyFontSize, font: regular),
          textAlign: pw.TextAlign.left)
      ];
    }
  }

  /// Creates a pw.TextSpan with appropriate styles for a snippet of text.
  static pw.InlineSpan _buildSpan(String text, Map<String, dynamic>? attr, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic) {
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
        fontSize: CVTheme.bodyFontSize,
        font: selectedFont,
        decoration: isUnderline ? pw.TextDecoration.underline : null,
      ),
    );
  }
}
