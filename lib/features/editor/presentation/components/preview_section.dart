import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


import 'package:smartcv_builder/features/editor/presentation/providers/cv_provider.dart';
import 'package:smartcv_builder/core/services/pdf_service.dart';
import 'package:smartcv_builder/core/models/cv_data.dart';


class DebouncedPdfPreview extends StatefulWidget {
  final CVData data;
  const DebouncedPdfPreview({super.key, required this.data});

  @override
  State<DebouncedPdfPreview> createState() => _DebouncedPdfPreviewState();
}

class _DebouncedPdfPreviewState extends State<DebouncedPdfPreview> {
  Timer? _debounceTimer;
  late CVData _previewData;
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
  void didUpdateWidget(DebouncedPdfPreview oldWidget) {
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
                onPressed: () => setState(() => _showTemplateSelector = !_showTemplateSelector),
                isActive: _showTemplateSelector,
              ),
              const VerticalDivider(width: 20, indent: 15, endIndent: 15),
              // Design/Style Settings
              _buildModernToolbarButton(
                icon: Icons.auto_awesome,
                label: 'Style',
                onPressed: () => _showStyleBottomSheet(context),
              ),
              const Spacer(),
              // Primary Actions
              _buildPrimaryActionButton(
                icon: Icons.file_download,
                label: 'Download',
                color: Colors.blue.shade700,
                onPressed: () async {
                  final bytes = await PDFService.generateCV(_previewData);
                  final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'My_CV';
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
                key: const ValueKey('cv_preview_stable'),
                build: (format) => PDFService.generateCV(_previewData),
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
              if (_showTemplateSelector)
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
    return PopupMenuButton<double>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.format_line_spacing, size: 18, color: Colors.blueGrey),
      tooltip: 'Line Height',
      onSelected: (val) {
        context.read<CVProvider>().updateLineHeight(val);
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
    return PopupMenuButton<double>(
      offset: const Offset(0, 40),
      tooltip: 'Font Size',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.format_size, size: 14, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(
              widget.data.baseFontSize.round().toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.blueGrey),
          ],
        ),
      ),
      onSelected: (val) {
        context.read<CVProvider>().updateBaseFontSize(val);
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
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      tooltip: 'Select Font',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aa',
              style: _getFontItemStyle(widget.data.fontFamily).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.blue.shade800),
          ],
        ),
      ),
      onSelected: (val) {
        context.read<CVProvider>().updateFontFamily(val);
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
              final bytes = await PDFService.generateCV(_previewData);
              final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'My_CV';
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

  Widget _buildModernToolbarButton({required IconData icon, required String label, required VoidCallback onPressed, bool isActive = false}) {
    return InkWell(
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
            Icon(icon, size: 20, color: isActive ? Colors.blue.shade700 : Colors.blueGrey.shade700),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.blue.shade700 : Colors.blueGrey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
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
            final data = context.watch<CVProvider>().cvData;
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

  Widget _buildLoadingWidget() {
    if (!_isInitialLoad) return const SizedBox.shrink();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'SmartCV is crafting your masterpiece...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue.shade700, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelectorOverlay(BuildContext context) {
    final currentTemplate = context.watch<CVProvider>().cvData.templateId;
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Template', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _showTemplateSelector = false),
                )
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableTemplates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = _availableTemplates[index];
                  final isSelected = currentTemplate == template['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      context.read<CVProvider>().changeTemplate(template['id']!);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: _buildTemplateLayoutPreview(template['id']!, isSelected),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          template['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue.shade800 : Colors.blueGrey,
                          ),
                        ),
                      ],
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

  PopupMenuItem<String> _buildFontItem(String value, String label, String current) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: current == value ? const Icon(Icons.check, size: 16) : null,
          ),
          Expanded(
            child: Text(label, style: _getFontItemStyle(value)),
          ),
        ],
      ),
    );
  }

  TextStyle _getFontItemStyle(String value) {
    String family = value;
    if (value == 'Poppins' || value == 'BundledPoppins') family = 'BundledPoppins';
    if (value == 'Tinos' || value == 'BundledTinos') family = 'BundledTinos';
    if (value == 'Roboto') family = 'Roboto';

    if (family.startsWith('Bundled')) {
      return TextStyle(fontFamily: family, fontSize: 13);
    }
    return GoogleFonts.getFont(value, fontSize: 13);
  }

  PopupMenuItem<double> _buildLineHeightItem(double value, String label, double current) {
    return PopupMenuItem<double>(
      value: value,
      child: Row(
        children: [
          SizedBox(width: 24, child: current == value ? const Icon(Icons.check, size: 16) : null),
          Text(label),
        ],
      ),
    );
  }

  PopupMenuItem<double> _buildFontSizeItem(double value, String label, double current) {
    return PopupMenuItem<double>(
      value: value,
      child: Row(
        children: [
          SizedBox(width: 24, child: current == value ? const Icon(Icons.check, size: 16) : null),
          Text(label),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final provider = context.read<CVProvider>();
    Color pickerColor = Color(int.parse(provider.cvData.primaryColorHex.replaceFirst('#', '0xff')));
    
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
                    provider.updatePrimaryColor(hex);
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

  Widget _buildTemplateLayoutPreview(String id, bool isSelected) {
    final primary = isSelected ? Colors.blue : Colors.grey.shade400;
    final secondary = isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 4),
          // Body layout simulation
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (id == 'modern' || id == 'creative') ...[
                  // Sidebar
                  Container(
                    width: 15,
                    color: secondary,
                  ),
                  const SizedBox(width: 4),
                ],
                // Main content lines
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      8,
                      (i) => Container(
                        height: 2,
                        width: (i % 3 == 0) ? double.infinity : (i % 2 == 0) ? 40 : 20,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class FullScreenPreview extends StatelessWidget {
  final CVData data;
  const FullScreenPreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade800,
        elevation: 0.5,
      ),
      body: PdfPreview(
        build: (format) => PDFService.generateCV(data),
        allowSharing: true,
        allowPrinting: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
