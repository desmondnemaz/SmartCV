import 'package:pdf/pdf.dart';

class CVTheme {
  // Font Sizes
  static const double headerTitleSize = 22.0;
  static const double headerJobTitleSize = 14.0;
  static const double sectionTitleSize = 16.0;
  static const double fieldLabelSize = 9.0;
  static const double fieldValueSize = 9.0;
  static const double itemTitleSize = 14.0;
  static const double itemTextSize = 11.0;
  static const double bodyFontSize = 10.0;
  
  // Colors
  static const PdfColor primaryColor = PdfColors.blue900;
  static const PdfColor secondaryColor = PdfColors.blueGrey800;
  static const PdfColor accentColor = PdfColors.blue800;
  static const PdfColor dividerColor = PdfColors.grey400;
  static const PdfColor textColor = PdfColors.black;
  static const PdfColor lightTextColor = PdfColors.grey700;

  // Spacing & Layout
  static const double pageMargin = 32.0;
  static const double sectionSpacing = 20.0;
  static const double itemSpacing = 12.0;
  static const double lineSpacing = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double fieldPaddingBottom = 2.0;
  static const double headerTitleBottomSpacing = 4.0;
  static const double headerAfterDividerSpacing = 12.0;
  static const double labelColumnWidth = 100.0;
  static const double labelValueGap = 20.0;
  
  // Line Thickness
  static const double headerDividerThickness = 2.0;
  static const double sectionDividerThickness = 1.0;
}
