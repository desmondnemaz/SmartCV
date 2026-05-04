import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;

class TemplateUtils {
  static Map<String, double> calculateFontSizes(double x) {
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

  /// Parses and renders rich text from Quill Delta JSON to PDF widgets.
  /// Supports bold, italic, underline, list bullets, numbering, and alignment.
  static List<pw.Widget> buildRichText(String jsonString, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic, double bodySize, double lh) {
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
                currentSpans.add(buildSpan(parts[i], attributes, regular, bold, italic, boldItalic, bodySize, lh));
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
            currentSpans.add(buildSpan(insert, attributes, regular, bold, italic, boldItalic, bodySize, lh));
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
  static pw.InlineSpan buildSpan(String text, Map<String, dynamic>? attr, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic, double bodySize, double lh) {
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
