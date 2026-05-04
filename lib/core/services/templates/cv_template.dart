import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartcv_builder/core/models/cv_data.dart';

abstract class CVTemplate {
  Future<Uint8List> generate(CVData data, pw.Font regular, pw.Font bold, pw.Font italic, pw.Font boldItalic);
}
