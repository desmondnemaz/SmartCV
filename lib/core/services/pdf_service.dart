import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/services/templates/cv_template.dart';
import 'package:smartcv_builder/core/services/templates/default_template.dart';
import 'package:smartcv_builder/core/services/templates/modern_template.dart';
import 'package:smartcv_builder/core/services/templates/metro_template.dart';

class PDFService {
  static String? _currentFontFamily;
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;
  static pw.Font? _fontItalic;
  static pw.Font? _fontBoldItalic;

  static Future<pw.Font> _loadFontSafe(Future<pw.Font> Function() onlineProvider, String? assetPath, {bool preferAsset = true}) async {
    // 1. Try Asset first if provided (always prefer asset for speed/offline)
    if (assetPath != null) {
      try {
        final data = await rootBundle.load('assets/$assetPath');
        return pw.Font.ttf(data);
      } catch (e) {
        // Fallback to online if asset fails or is missing
      }
    }

    // 2. Try Online (with shorter timeout)
    try {
      return await onlineProvider().timeout(const Duration(seconds: 3));
    } catch (_) {
      // 3. Final safety fallback to built-in Helvetica fonts
      if (assetPath != null) {
        final lower = assetPath.toLowerCase();
        if (lower.contains('bolditalic') || (lower.contains('bold') && lower.contains('italic'))) {
          return pw.Font.helveticaBoldOblique();
        }
        if (lower.contains('bold')) return pw.Font.helveticaBold();
        if (lower.contains('italic')) return pw.Font.helveticaOblique();
      }
      return pw.Font.helvetica();
    }
  }


  static bool _isLoading = false;

  static Future<void> _loadFonts(String fontFamily) async {
    if (_currentFontFamily == fontFamily && _fontRegular != null) return;
    
    // Simple lock to prevent multiple concurrent loads
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_currentFontFamily == fontFamily && _fontRegular != null) return;
    }

    _isLoading = true;
    _currentFontFamily = fontFamily;

    try {
      Future<pw.Font> reg, bld, itl, bitl;

      switch (fontFamily) {
        case 'Arimo':
          reg = _loadFontSafe(PdfGoogleFonts.arimoRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.arimoBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.arimoItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.arimoBoldItalic, null);
          break;
        case 'Carlito':
          reg = _loadFontSafe(PdfGoogleFonts.carlitoRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.carlitoBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.carlitoItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.carlitoBoldItalic, null);
          break;
        case 'Courier Prime':
          reg = _loadFontSafe(PdfGoogleFonts.courierPrimeRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.courierPrimeBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.courierPrimeItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.courierPrimeBoldItalic, null);
          break;
        case 'Open Sans':
          reg = _loadFontSafe(PdfGoogleFonts.openSansRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.openSansBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.openSansItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.openSansBoldItalic, null);
          break;
        case 'Gelasio':
          reg = _loadFontSafe(PdfGoogleFonts.gelasioRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.gelasioBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.gelasioItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.gelasioBoldItalic, null);
          break;
        case 'Lato':
          reg = _loadFontSafe(PdfGoogleFonts.latoRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.latoBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.latoItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.latoBoldItalic, null);
          break;
        case 'Noto Sans':
          reg = _loadFontSafe(PdfGoogleFonts.notoSansRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.notoSansBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.notoSansItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.notoSansBoldItalic, null);
          break;
        case 'Noto Serif':
          reg = _loadFontSafe(PdfGoogleFonts.notoSerifRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.notoSerifBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.notoSerifItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.notoSerifBoldItalic, null);
          break;
        case 'Source Sans 3':
          reg = _loadFontSafe(PdfGoogleFonts.sourceSans3Regular, null);
          bld = _loadFontSafe(PdfGoogleFonts.sourceSans3Bold, null);
          itl = _loadFontSafe(PdfGoogleFonts.sourceSans3Italic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.sourceSans3BoldItalic, null);
          break;
        case 'Roboto':
          reg = _loadFontSafe(PdfGoogleFonts.robotoRegular, null);
          bld = _loadFontSafe(PdfGoogleFonts.robotoBold, null);
          itl = _loadFontSafe(PdfGoogleFonts.robotoItalic, null);
          bitl = _loadFontSafe(PdfGoogleFonts.robotoBoldItalic, null);
          break;
        case 'BundledTinos':
        case 'Tinos':
          reg = _loadFontSafe(PdfGoogleFonts.tinosRegular, 'fonts/Tinos-Regular.ttf');
          bld = _loadFontSafe(PdfGoogleFonts.tinosBold, 'fonts/Tinos-Bold.ttf');
          itl = _loadFontSafe(PdfGoogleFonts.tinosItalic, 'fonts/Tinos-Italic.ttf');
          bitl = _loadFontSafe(PdfGoogleFonts.tinosBoldItalic, 'fonts/Tinos-BoldItalic.ttf');
          break;
        case 'BundledPoppins':
        case 'Poppins':
        default:
          reg = _loadFontSafe(PdfGoogleFonts.poppinsRegular, 'fonts/Poppins-Regular.ttf');
          bld = _loadFontSafe(PdfGoogleFonts.poppinsBold, 'fonts/Poppins-Bold.ttf');
          itl = _loadFontSafe(PdfGoogleFonts.poppinsItalic, 'fonts/Poppins-Regular.ttf');
          bitl = _loadFontSafe(PdfGoogleFonts.poppinsBoldItalic, 'fonts/Poppins-Bold.ttf');
          break;
      }

      final fonts = await Future.wait([reg, bld, itl, bitl]);
      _fontRegular = fonts[0];
      _fontBold = fonts[1];
      _fontItalic = fonts[2];
      _fontBoldItalic = fonts[3];
    } finally {
      _isLoading = false;
    }
  }

  static Future<Uint8List> generateCV(CVData data) async {
    await _loadFonts(data.fontFamily);

    // Final safety check to avoid null operator crash
    final regular = _fontRegular ?? await _loadFontSafe(PdfGoogleFonts.poppinsRegular, 'fonts/Poppins-Regular.ttf');
    final bold = _fontBold ?? await _loadFontSafe(PdfGoogleFonts.poppinsBold, 'fonts/Poppins-Bold.ttf');
    final italic = _fontItalic ?? await _loadFontSafe(PdfGoogleFonts.poppinsItalic, 'fonts/Poppins-Regular.ttf');
    final boldItalic = _fontBoldItalic ?? await _loadFontSafe(PdfGoogleFonts.poppinsBoldItalic, 'fonts/Poppins-Bold.ttf');

    CVTemplate template;
    switch (data.templateId) {
      case 'metro':
        template = MetroTemplate();
        break;
      case 'modern':
        template = ModernTemplate();
        break;
      case 'default':
      default:
        template = DefaultTemplate();
    }

    return template.generate(data, regular, bold, italic, boldItalic);
  }
}
