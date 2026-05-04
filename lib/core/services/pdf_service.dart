import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';
import 'package:smartcv_builder/core/theme/cv_theme.dart';
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

  static Future<pw.Font> _loadFontSafe(Future<pw.Font> Function() onlineProvider, String? assetPath, {bool preferAsset = false}) async {
    try {
      // Attempt to load from Google Fonts with a generous timeout
      return await onlineProvider().timeout(const Duration(seconds: 15));
    } catch (_) {
      // Fallback to built-in PDF fonts if online fails to absolutely prevent TTF parsing crashes
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
      switch (fontFamily) {
        case 'Arimo':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.arimoRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.arimoBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.arimoItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.arimoBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'Carlito':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.carlitoRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.carlitoBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.carlitoItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.carlitoBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'Courier Prime':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.courierPrimeRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.courierPrimeBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.courierPrimeItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.courierPrimeBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'Open Sans':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.openSansRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.openSansBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.openSansItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.openSansBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'BundledGaramond':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.notoSerifRegular, 'fonts/EBGaramond-Regular.ttf', preferAsset: true);
          _fontBold = await _loadFontSafe(PdfGoogleFonts.notoSerifBold, 'fonts/EBGaramond-Bold.ttf', preferAsset: true);
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifItalic, 'fonts/EBGaramond-Regular.ttf', preferAsset: true);
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifBoldItalic, 'fonts/EBGaramond-Bold.ttf', preferAsset: true);
          break;
        case 'EBGaramond':
        case 'Noto Serif':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.notoSerifRegular, 'fonts/EBGaramond-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.notoSerifBold, 'fonts/EBGaramond-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifItalic, 'fonts/EBGaramond-Regular.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.notoSerifBoldItalic, 'fonts/EBGaramond-Bold.ttf');
          break;
        case 'Gelasio':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.gelasioRegular, 'fonts/EBGaramond-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.gelasioBold, 'fonts/EBGaramond-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.gelasioItalic, 'fonts/EBGaramond-Regular.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.gelasioBoldItalic, 'fonts/EBGaramond-Bold.ttf');
          break;
        case 'Lato':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.latoRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.latoBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.latoItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.latoBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'Noto Sans':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.notoSansRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.notoSansBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.notoSansItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.notoSansBoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'BundledPoppins':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.poppinsRegular, 'fonts/Poppins-Regular.ttf', preferAsset: true);
          _fontBold = await _loadFontSafe(PdfGoogleFonts.poppinsBold, 'fonts/Poppins-Bold.ttf', preferAsset: true);
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.poppinsItalic, 'fonts/Poppins-Regular.ttf', preferAsset: true);
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.poppinsBoldItalic, 'fonts/Poppins-Bold.ttf', preferAsset: true);
          break;
        case 'Poppins':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.poppinsRegular, 'fonts/Poppins-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.poppinsBold, 'fonts/Poppins-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.poppinsItalic, 'fonts/Poppins-Regular.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.poppinsBoldItalic, 'fonts/Poppins-Bold.ttf');
          break;
        case 'BundledTinos':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.tinosRegular, 'fonts/Tinos-Regular.ttf', preferAsset: true);
          _fontBold = await _loadFontSafe(PdfGoogleFonts.tinosBold, 'fonts/Tinos-Bold.ttf', preferAsset: true);
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.tinosItalic, 'fonts/Tinos-Italic.ttf', preferAsset: true);
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.tinosBoldItalic, 'fonts/Tinos-BoldItalic.ttf', preferAsset: true);
          break;
        case 'Tinos':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.tinosRegular, 'fonts/Tinos-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.tinosBold, 'fonts/Tinos-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.tinosItalic, 'fonts/Tinos-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.tinosBoldItalic, 'fonts/Tinos-BoldItalic.ttf');
          break;
        case 'Source Sans 3':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.sourceSans3Regular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.sourceSans3Bold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.sourceSans3Italic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.sourceSans3BoldItalic, 'fonts/Roboto-Bold.ttf');
          break;
        case 'BundledRoboto':
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.robotoRegular, 'fonts/Roboto-Regular.ttf', preferAsset: true);
          _fontBold = await _loadFontSafe(PdfGoogleFonts.robotoBold, 'fonts/Roboto-Bold.ttf', preferAsset: true);
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.robotoItalic, 'fonts/Roboto-Italic.ttf', preferAsset: true);
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.robotoBoldItalic, 'fonts/Roboto-Bold.ttf', preferAsset: true);
          break;
        case 'Roboto':
        default:
          _fontRegular = await _loadFontSafe(PdfGoogleFonts.robotoRegular, 'fonts/Roboto-Regular.ttf');
          _fontBold = await _loadFontSafe(PdfGoogleFonts.robotoBold, 'fonts/Roboto-Bold.ttf');
          _fontItalic = await _loadFontSafe(PdfGoogleFonts.robotoItalic, 'fonts/Roboto-Italic.ttf');
          _fontBoldItalic = await _loadFontSafe(PdfGoogleFonts.robotoBoldItalic, 'fonts/Roboto-Bold.ttf');
      }
    } finally {
      _isLoading = false;
    }
  }

  static Future<Uint8List> generateCV(CVData data) async {
    await _loadFonts(data.fontFamily);

    // Final safety check to avoid null operator crash
    final regular = _fontRegular ?? await _loadFontSafe(PdfGoogleFonts.robotoRegular, 'fonts/Roboto-Regular.ttf');
    final bold = _fontBold ?? await _loadFontSafe(PdfGoogleFonts.robotoBold, 'fonts/Roboto-Bold.ttf');
    final italic = _fontItalic ?? await _loadFontSafe(PdfGoogleFonts.robotoItalic, 'fonts/Roboto-Italic.ttf');
    final boldItalic = _fontBoldItalic ?? await _loadFontSafe(PdfGoogleFonts.robotoBoldItalic, 'fonts/Roboto-Bold.ttf');

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
