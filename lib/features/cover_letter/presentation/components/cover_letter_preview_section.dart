import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:smartcv_builder/features/cover_letter/presentation/providers/cover_letter_provider.dart';
import 'package:smartcv_builder/core/services/pdf_service.dart';
import 'package:smartcv_builder/core/models/cover_letter_data.dart';

class DebouncedCoverLetterPreview extends StatefulWidget {
  final CoverLetterData data;
  const DebouncedCoverLetterPreview({super.key, required this.data});

  @override
  State<DebouncedCoverLetterPreview> createState() => _DebouncedCoverLetterPreviewState();
}

class _DebouncedCoverLetterPreviewState extends State<DebouncedCoverLetterPreview> {
  Timer? _debounceTimer;
  late CoverLetterData _previewData;
  double _maxPageWidth = 550.0;
  bool _isInitialLoad = true;
  bool _isUpdating = false;
  bool _showTemplateSelector = false;

  final List<Map<String, String>> _availableTemplates = [
    {'id': 'default', 'name': 'Simple'},
    {'id': 'modern', 'name': 'Modern'},
    {'id': 'metro', 'name': 'Metro'},
    {'id': 'executive', 'name': 'Executive'},
    {'id': 'creative', 'name': 'Creative'},
  ];

  @override
  void initState() {
    super.initState();
    _previewData = widget.data;
  }

  @override
  void didUpdateWidget(DebouncedCoverLetterPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debounceTimer?.cancel();
    setState(() => _isUpdating = true);
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _previewData = widget.data;
          _isInitialLoad = false;
          _isUpdating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLinked = _previewData.linkedCvId != null;

    return Column(
      children: [
        Container(
          height: 56,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Template Selector Toggle
              _buildModernToolbarButton(
                icon: Icons.dashboard_customize,
                label: 'Layout',
                onPressed: isLinked
                    ? null
                    : () => setState(() => _showTemplateSelector = !_showTemplateSelector),
                isActive: _showTemplateSelector && !isLinked,
                disabledTooltip: 'Synced with resume layout',
              ),
              const VerticalDivider(width: 20, indent: 15, endIndent: 15),
              // Design/Style Settings
              _buildModernToolbarButton(
                icon: Icons.auto_awesome,
                label: 'Style',
                onPressed: isLinked
                    ? null
                    : () => _showStyleBottomSheet(context),
                disabledTooltip: 'Synced with resume style',
              ),
              if (isLinked) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 14, color: Colors.blue.shade800),
                      const SizedBox(width: 6),
                      Text(
                        'Synced with Resume',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Primary Actions
              _buildPrimaryActionButton(
                icon: Icons.file_download,
                label: 'Download',
                color: Colors.blue.shade700,
                onPressed: () async {
                  final bytes = await PDFService.generateCoverLetter(_previewData);
                  final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'Cover_Letter';
                  await Printing.sharePdf(bytes: bytes, filename: '$name.pdf');
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              PdfPreview(
                key: const ValueKey('cl_preview_stable'),
                build: (format) => PDFService.generateCoverLetter(_previewData),
                allowSharing: false,
                allowPrinting: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                maxPageWidth: _maxPageWidth,
                loadingWidget: _buildLoadingWidget(),
              ),
              if (_isUpdating)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              if (_showTemplateSelector && !isLinked)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildTemplateSelectorOverlay(context),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildBottomToolbar(context),
      ],
    );
  }

  Widget _buildLineHeightMenu(BuildContext context) {
    final isLinked = widget.data.linkedCvId != null;
    return PopupMenuButton<double>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.format_line_spacing, size: 18, color: isLinked ? Colors.grey : Colors.blueGrey),
      tooltip: isLinked ? 'Synced' : 'Line Height',
      enabled: !isLinked,
      onSelected: (val) {
        context.read<CoverLetterProvider>().updateStyling(lineHeight: val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('LINE HEIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        _buildLineHeightItem(1.0, '1', widget.data.lineHeight),
        _buildLineHeightItem(1.15, '1.15', widget.data.lineHeight),
        _buildLineHeightItem(1.25, '1.25', widget.data.lineHeight),
        _buildLineHeightItem(1.5, '1.5', widget.data.lineHeight),
        _buildLineHeightItem(2.0, '2', widget.data.lineHeight),
      ],
    );
  }

  Widget _buildFontSizeMenu(BuildContext context) {
    final isLinked = widget.data.linkedCvId != null;
    return PopupMenuButton<double>(
      offset: const Offset(0, 40),
      tooltip: isLinked ? 'Synced' : 'Font Size',
      enabled: !isLinked,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLinked ? Colors.grey.shade100 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLinked ? Colors.grey.shade200 : Colors.blueGrey.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_size, size: 14, color: isLinked ? Colors.grey : Colors.blueGrey),
            const SizedBox(width: 4),
            Text(
              widget.data.baseFontSize.round().toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLinked ? Colors.grey : Colors.blueGrey,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 12, color: isLinked ? Colors.grey : Colors.blueGrey),
          ],
        ),
      ),
      onSelected: (val) {
        context.read<CoverLetterProvider>().updateStyling(baseFontSize: val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('FONT SIZE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        _buildFontSizeItem(10.0, '10', widget.data.baseFontSize),
        _buildFontSizeItem(11.0, '11', widget.data.baseFontSize),
        _buildFontSizeItem(12.0, '12', widget.data.baseFontSize),
        _buildFontSizeItem(13.0, '13', widget.data.baseFontSize),
        _buildFontSizeItem(14.0, '14', widget.data.baseFontSize),
      ],
    );
  }

  Widget _buildFontFamilyMenu(BuildContext context) {
    final isLinked = widget.data.linkedCvId != null;
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      tooltip: isLinked ? 'Synced' : 'Select Font',
      enabled: !isLinked,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLinked ? Colors.grey.shade100 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLinked ? Colors.grey.shade200 : Colors.blue.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aa',
              style: _getFontItemStyle(widget.data.fontFamily).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLinked ? Colors.grey : Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 12, color: isLinked ? Colors.grey : Colors.blue.shade800),
          ],
        ),
      ),
      onSelected: (val) {
        context.read<CoverLetterProvider>().updateStyling(fontFamily: val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('FONT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...[
          const PopupMenuItem<String>(
            enabled: false,
            child: Text('BUNDLED (OFFLINE SAFE)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          {'name': 'BundledPoppins', 'label': 'Poppins'},
          {'name': 'BundledTinos', 'label': 'Times New Roman'},
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            enabled: false,
            child: Text('ONLINE ALTERNATIVES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
          {'name': 'Arimo', 'label': 'Arial'},
          {'name': 'Carlito', 'label': 'Calibri'},
          {'name': 'Courier Prime', 'label': 'Courier New'},
          {'name': 'Open Sans', 'label': 'DejaVu Sans'},
          {'name': 'Gelasio', 'label': 'Georgia'},
          {'name': 'Lato', 'label': 'Lato'},
          {'name': 'Noto Sans', 'label': 'Noto Sans'},
          {'name': 'Noto Serif', 'label': 'Noto Serif'},
          {'name': 'Roboto', 'label': 'Roboto'},
          {'name': 'Source Sans 3', 'label': 'Trebuchet'},
        ].map<PopupMenuEntry<String>>((f) {
          if (f is PopupMenuEntry<String>) return f;
          final map = f as Map<String, String>;
          return _buildFontItem(map['name']!, map['label']!, widget.data.fontFamily);
        }),
      ],
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 20, color: Colors.blueGrey),
            tooltip: 'Print',
            onPressed: () async {
              final bytes = await PDFService.generateCoverLetter(_previewData);
              final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'Cover_Letter';
              await Printing.layoutPdf(onLayout: (format) => bytes, name: name);
            },
          ),
          const VerticalDivider(width: 24, indent: 12, endIndent: 12),
          Text(
            'Preview Zoom: ${((_maxPageWidth / 550) * 100).round()}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => setState(() => _maxPageWidth = (_maxPageWidth - 100).clamp(300.0, 1500.0)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => setState(() => _maxPageWidth = (_maxPageWidth + 100).clamp(300.0, 1500.0)),
          ),
          const VerticalDivider(width: 24, indent: 12, endIndent: 12),
          IconButton(
            icon: const Icon(Icons.fullscreen_exit, size: 20, color: Colors.blueGrey),
            tooltip: 'Reset Zoom',
            onPressed: () => setState(() => _maxPageWidth = 550.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isInitialLoad ? 'Loading fonts & content...' : 'Updating preview...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
    String? disabledTooltip,
  }) {
    final isEnabled = onPressed != null;
    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? (isActive ? Colors.blue.shade700 : Colors.blueGrey.shade700)
                  : Colors.grey.shade300,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isEnabled
                    ? (isActive ? Colors.blue.shade700 : Colors.blueGrey.shade700)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );

    if (!isEnabled && disabledTooltip != null) {
      button = Tooltip(
        message: disabledTooltip,
        child: button,
      );
    }

    return button;
  }

  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildTemplateSelectorOverlay(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SELECT LETTERHEAD LAYOUT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () => setState(() => _showTemplateSelector = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTemplates.length,
                itemBuilder: (context, index) {
                  final t = _availableTemplates[index];
                  final isSelected = widget.data.templateId == t['id'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        context.read<CoverLetterProvider>().updateStyling(templateId: t['id']);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          t['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue.shade800 : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStyleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final data = context.watch<CoverLetterProvider>().coverLetterData;
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Style Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Font Selection
                  _buildStyleOption(
                    label: 'Typography',
                    icon: Icons.font_download,
                    child: _buildFontFamilyMenu(context),
                  ),
                  const SizedBox(height: 20),
                  // Font Size
                  _buildStyleOption(
                    label: 'Text Size',
                    icon: Icons.format_size,
                    child: _buildFontSizeMenu(context),
                  ),
                  const SizedBox(height: 20),
                  // Line Height
                  _buildStyleOption(
                    label: 'Line Spacing',
                    icon: Icons.format_line_spacing,
                    child: _buildLineHeightMenu(context),
                  ),
                  const SizedBox(height: 20),
                  // Color Picker
                  _buildStyleOption(
                    label: 'Theme Color',
                    icon: Icons.palette,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showColorPicker(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(int.parse(data.primaryColorHex.replaceFirst('#', '0xff'))),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Pick Color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    final provider = context.read<CoverLetterProvider>();
    Color pickerColor = Color(int.parse(provider.coverLetterData.primaryColorHex.replaceFirst('#', '0xff')));
    
    final commonColors = [
      {'color': const Color(0xFF2C3E50), 'label': 'Navy'},
      {'color': const Color(0xFF2980B9), 'label': 'Royal'},
      {'color': const Color(0xFF27AE60), 'label': 'Green'},
      {'color': const Color(0xFFC0392B), 'label': 'Red'},
      {'color': const Color(0xFF333333), 'label': 'Charcoal'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pick Title Color'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Common Presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: commonColors.map((cp) {
                        final color = cp['color'] as Color;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              pickerColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: pickerColor == color ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: pickerColor == color 
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (color) {
                        setDialogState(() {
                          pickerColor = color;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    final hex = '#${pickerColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
                    provider.updateStyling(primaryColorHex: hex);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildStyleOption({required String label, required IconData icon, required Widget child}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        const Spacer(),
        child,
      ],
    );
  }

  PopupMenuEntry<double> _buildLineHeightItem(double val, String label, double current) {
    final isSelected = val == current;
    return PopupMenuItem<double>(
      value: val,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (isSelected) const Icon(Icons.check, size: 14, color: Colors.blue),
        ],
      ),
    );
  }

  PopupMenuEntry<double> _buildFontSizeItem(double val, String label, double current) {
    final isSelected = val == current;
    return PopupMenuItem<double>(
      value: val,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (isSelected) const Icon(Icons.check, size: 14, color: Colors.blue),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildFontItem(String val, String label, String current) {
    final isSelected = val == current;
    return PopupMenuItem<String>(
      value: val,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: _getFontItemStyle(val).copyWith(fontSize: 13),
          ),
          if (isSelected) const Icon(Icons.check, size: 14, color: Colors.blue),
        ],
      ),
    );
  }

  TextStyle _getFontItemStyle(String fontFamily) {
    switch (fontFamily) {
      case 'Arimo':
        return GoogleFonts.arimo();
      case 'Carlito':
        return GoogleFonts.carlito();
      case 'Courier Prime':
        return GoogleFonts.courierPrime();
      case 'Open Sans':
        return GoogleFonts.openSans();
      case 'Gelasio':
        return GoogleFonts.gelasio();
      case 'Lato':
        return GoogleFonts.lato();
      case 'Noto Sans':
        return GoogleFonts.notoSans();
      case 'Noto Serif':
        return GoogleFonts.notoSerif();
      case 'Source Sans 3':
        return GoogleFonts.sourceSans3();
      case 'Roboto':
        return GoogleFonts.roboto();
      case 'BundledTinos':
      case 'Tinos':
        return GoogleFonts.tinos();
      case 'BundledPoppins':
      case 'Poppins':
      default:
        return GoogleFonts.poppins();
    }
  }
}
