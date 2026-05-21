import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cover_letter_data.dart';
import 'package:smartcv_builder/core/services/templates/template_utils.dart';

class CoverLetterTemplates {
  static Future<Uint8List> generate(
    CoverLetterData data,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: italic,
        boldItalic: boldItalic,
      ),
    );

    final primaryColor = PdfColor.fromInt(
      int.parse(data.primaryColorHex.replaceFirst('#', '0xff')),
    );
    final sizes = TemplateUtils.calculateFontSizes(data.baseFontSize);
    final lh = data.lineHeight;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: data.templateId == 'modern' || data.templateId == 'creative'
            ? const pw.EdgeInsets.all(0)
            : const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 54),
        build: (pw.Context context) {
          switch (data.templateId) {
            case 'modern':
              return _buildModernLayout(data, sizes, lh, primaryColor, regular, bold, italic, boldItalic);
            case 'metro':
              return _buildMetroLayout(data, sizes, lh, primaryColor, regular, bold, italic, boldItalic);
            case 'executive':
              return _buildExecutiveLayout(data, sizes, lh, primaryColor, regular, bold, italic, boldItalic);
            case 'creative':
              return _buildCreativeLayout(data, sizes, lh, primaryColor, regular, bold, italic, boldItalic);
            case 'default':
            default:
              return _buildDefaultLayout(data, sizes, lh, primaryColor, regular, bold, italic, boldItalic);
          }
        },
      ),
    );

    return pdf.save();
  }

  // Helper: Builds the core business letter block (date, subject, body text)
  static List<pw.Widget> _buildLetterBodyWidgets(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
    PdfColor primaryColor,
  ) {
    final double bodySize = sizes['body'] ?? 10.0;
    
    return [
      // Date Block
      if (data.date.isNotEmpty) ...[
        pw.Text(
          data.date,
          style: pw.TextStyle(fontSize: bodySize, color: PdfColors.grey600, lineSpacing: bodySize * (lh - 1.0)),
        ),
        pw.SizedBox(height: 18),
      ],

      // Subject Block
      if (data.subjectLine.isNotEmpty) ...[
        pw.Text(
          data.subjectLine.toUpperCase(),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: bodySize + 1, color: primaryColor, lineSpacing: (bodySize + 1) * (lh - 1.0)),
        ),
        pw.SizedBox(height: 14),
      ],

      // Rich text letter paragraphs (recipient, salutation, body text, closing, signature)
      if (data.body.isNotEmpty) ...[
        ...TemplateUtils.buildRichText(
          data.body,
          regular,
          bold,
          italic,
          boldItalic,
          bodySize,
          lh,
        ),
      ],
    ];
  }

  // 1. DEFAULT STYLE
  static List<pw.Widget> _buildDefaultLayout(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    PdfColor primaryColor,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) {
    final titleAlign = _getCrossAxisAlignment(data.headerAlignment);
    final align = _getAlignment(data.headerAlignment);

    final titleText = data.showNameAsHeader
        ? (data.senderName.isNotEmpty ? data.senderName.toUpperCase() : 'SENDER NAME')
        : 'COVER LETTER';

    final subtitleText = data.showNameAsHeader
        ? data.senderJobTitle
        : (data.senderName.isNotEmpty ? '${data.senderName}  |  ${data.senderJobTitle}' : data.senderJobTitle);

    return [
      // Sender Header
      pw.Align(
        alignment: align,
        child: pw.Column(
          crossAxisAlignment: titleAlign,
          children: [
            pw.Text(
              titleText,
              style: pw.TextStyle(
                fontSize: sizes['headerTitle'] ?? 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            if (subtitleText.isNotEmpty)
              pw.Text(
                subtitleText,
                style: pw.TextStyle(
                  fontSize: sizes['headerJobTitle'] ?? 12,
                  color: PdfColors.grey700,
                ),
              ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (data.senderEmail.isNotEmpty)
                  pw.Text(data.senderEmail, style: const pw.TextStyle(fontSize: 9)),
                if (data.senderEmail.isNotEmpty && data.senderPhone.isNotEmpty)
                  pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                if (data.senderPhone.isNotEmpty)
                  pw.Text(data.senderPhone, style: const pw.TextStyle(fontSize: 9)),
                if ((data.senderEmail.isNotEmpty || data.senderPhone.isNotEmpty) && data.senderAddress.isNotEmpty)
                  pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                if (data.senderAddress.isNotEmpty)
                  pw.Text(data.senderAddress, style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: primaryColor, thickness: 1.5),
      pw.SizedBox(height: 24),
      
      // Letter Content
      ..._buildLetterBodyWidgets(data, sizes, lh, regular, bold, italic, boldItalic, primaryColor),
    ];
  }

  // 2. MODERN STYLE (Full bleed top header)
  static List<pw.Widget> _buildModernLayout(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    PdfColor primaryColor,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) {
    final titleAlign = _getCrossAxisAlignment(data.headerAlignment);
    final align = _getAlignment(data.headerAlignment);

    final titleText = data.showNameAsHeader
        ? (data.senderName.isNotEmpty ? data.senderName.toUpperCase() : 'SENDER NAME')
        : 'COVER LETTER';

    final subtitleText = data.showNameAsHeader
        ? data.senderJobTitle
        : (data.senderName.isNotEmpty ? '${data.senderName}  |  ${data.senderJobTitle}' : data.senderJobTitle);

    return [
      // Top Colored Banner with Sender Header details
      pw.Container(
        color: primaryColor,
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 36),
        child: pw.Align(
          alignment: align,
          child: pw.Column(
            crossAxisAlignment: titleAlign,
            children: [
              pw.Text(
                titleText,
                style: pw.TextStyle(
                  fontSize: (sizes['headerTitle'] ?? 20) + 4,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 2,
                ),
              ),
              if (subtitleText.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitleText.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: sizes['headerJobTitle'] ?? 12,
                    color: PdfColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  if (data.senderEmail.isNotEmpty)
                    pw.Text(data.senderEmail, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                  if (data.senderEmail.isNotEmpty && data.senderPhone.isNotEmpty)
                    pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                  if (data.senderPhone.isNotEmpty)
                    pw.Text(data.senderPhone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                  if ((data.senderEmail.isNotEmpty || data.senderPhone.isNotEmpty) && data.senderAddress.isNotEmpty)
                    pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                  if (data.senderAddress.isNotEmpty)
                    pw.Text(data.senderAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Document content with normal margin padding
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 36),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _buildLetterBodyWidgets(data, sizes, lh, regular, bold, italic, boldItalic, primaryColor),
        ),
      ),
    ];
  }

  // 3. METRO STYLE (Top layout with small vertical accent)
  static List<pw.Widget> _buildMetroLayout(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    PdfColor primaryColor,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) {
    final titleAlign = _getCrossAxisAlignment(data.headerAlignment);
    final align = _getAlignment(data.headerAlignment);

    final titleText = data.showNameAsHeader
        ? (data.senderName.isNotEmpty ? data.senderName.toUpperCase() : 'SENDER NAME')
        : 'COVER LETTER';

    final subtitleText = data.showNameAsHeader
        ? data.senderJobTitle
        : (data.senderName.isNotEmpty ? '${data.senderName}  |  ${data.senderJobTitle}' : data.senderJobTitle);

    return [
      pw.Align(
        alignment: align,
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 50,
              color: primaryColor,
            ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: titleAlign,
              children: [
                pw.Text(
                  titleText,
                  style: pw.TextStyle(
                    fontSize: sizes['headerTitle'] ?? 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                if (subtitleText.isNotEmpty)
                  pw.Text(
                    subtitleText,
                    style: pw.TextStyle(
                      fontSize: sizes['headerJobTitle'] ?? 12,
                      color: primaryColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    if (data.senderEmail.isNotEmpty)
                      pw.Text(data.senderEmail, style: const pw.TextStyle(fontSize: 9)),
                    if (data.senderEmail.isNotEmpty && data.senderPhone.isNotEmpty)
                      pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    if (data.senderPhone.isNotEmpty)
                      pw.Text(data.senderPhone, style: const pw.TextStyle(fontSize: 9)),
                    if ((data.senderEmail.isNotEmpty || data.senderPhone.isNotEmpty) && data.senderAddress.isNotEmpty)
                      pw.Text('   •   ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    if (data.senderAddress.isNotEmpty)
                      pw.Text(data.senderAddress, style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 32),
      
      ..._buildLetterBodyWidgets(data, sizes, lh, regular, bold, italic, boldItalic, primaryColor),
    ];
  }

  // 4. EXECUTIVE STYLE (Centered elegant letterhead)
  static List<pw.Widget> _buildExecutiveLayout(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    PdfColor primaryColor,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) {
    final titleText = data.showNameAsHeader
        ? (data.senderName.isNotEmpty ? data.senderName.toUpperCase() : 'SENDER NAME')
        : 'COVER LETTER';

    final subtitleText = data.showNameAsHeader
        ? data.senderJobTitle
        : (data.senderName.isNotEmpty ? '${data.senderName}  |  ${data.senderJobTitle}' : data.senderJobTitle);

    return [
      // Centered Title Block
      pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Column(
          children: [
            pw.Text(
              titleText,
              style: pw.TextStyle(
                fontSize: sizes['headerTitle'] ?? 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 2.5,
              ),
            ),
            if (subtitleText.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                subtitleText.toUpperCase(),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
            pw.SizedBox(height: 8),
            pw.Container(height: 0.5, color: PdfColors.grey500, width: 150),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (data.senderEmail.isNotEmpty)
                  pw.Text(data.senderEmail, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                if (data.senderEmail.isNotEmpty && data.senderPhone.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
                if (data.senderPhone.isNotEmpty)
                  pw.Text(data.senderPhone, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                if ((data.senderEmail.isNotEmpty || data.senderPhone.isNotEmpty) && data.senderAddress.isNotEmpty)
                  pw.Text('  |  ', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
                if (data.senderAddress.isNotEmpty)
                  pw.Text(data.senderAddress, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 40),

      ..._buildLetterBodyWidgets(data, sizes, lh, regular, bold, italic, boldItalic, primaryColor),
    ];
  }

  // 5. CREATIVE STYLE (Asymmetric top color block with sidebar contact block)
  static List<pw.Widget> _buildCreativeLayout(
    CoverLetterData data,
    Map<String, double> sizes,
    double lh,
    PdfColor primaryColor,
    pw.Font regular,
    pw.Font bold,
    pw.Font italic,
    pw.Font boldItalic,
  ) {
    final titleText = data.showNameAsHeader
        ? (data.senderName.isNotEmpty ? data.senderName.toUpperCase() : 'SENDER NAME')
        : 'COVER LETTER';

    final subtitleText = data.showNameAsHeader
        ? data.senderJobTitle
        : (data.senderName.isNotEmpty ? '${data.senderName}  |  ${data.senderJobTitle}' : data.senderJobTitle);

    return [
      // Top Color Block
      pw.Container(
        color: primaryColor,
        width: double.infinity,
        padding: const pw.EdgeInsets.only(left: 54, right: 54, top: 40, bottom: 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titleText,
              style: pw.TextStyle(
                fontSize: (sizes['headerTitle'] ?? 20) + 6,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 2,
              ),
            ),
            if (subtitleText.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                subtitleText.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: sizes['headerJobTitle'] ?? 12,
                  color: const PdfColor(1.0, 1.0, 1.0, 0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),

      // Page Contents
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 54, vertical: 30),
        child: pw.Partitions(
          children: [
            // Left column: Sender contact info
            pw.Partition(
              width: 140,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(right: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CONTACT',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(height: 1, width: 30, color: primaryColor),
                    pw.SizedBox(height: 8),
                    if (data.senderEmail.isNotEmpty) ...[
                      pw.Text('Email', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.grey600)),
                      pw.Text(data.senderEmail, style: const pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(height: 6),
                    ],
                    if (data.senderPhone.isNotEmpty) ...[
                      pw.Text('Phone', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.grey600)),
                      pw.Text(data.senderPhone, style: const pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(height: 6),
                    ],
                    if (data.senderAddress.isNotEmpty) ...[
                      pw.Text('Address', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.grey600)),
                      pw.Text(data.senderAddress, style: const pw.TextStyle(fontSize: 8)),
                      pw.SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),

            // Right column: Main Letter Body
            pw.Partition(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _buildLetterBodyWidgets(data, sizes, lh, regular, bold, italic, boldItalic, primaryColor),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  static pw.CrossAxisAlignment _getCrossAxisAlignment(String alignment) {
    switch (alignment) {
      case 'center':
        return pw.CrossAxisAlignment.center;
      case 'right':
        return pw.CrossAxisAlignment.end;
      case 'left':
      default:
        return pw.CrossAxisAlignment.start;
    }
  }

  static pw.Alignment _getAlignment(String alignment) {
    switch (alignment) {
      case 'center':
        return pw.Alignment.center;
      case 'right':
        return pw.Alignment.topRight;
      case 'left':
      default:
        return pw.Alignment.topLeft;
    }
  }
}
