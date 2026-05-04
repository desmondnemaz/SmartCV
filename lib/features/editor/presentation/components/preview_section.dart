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
    {'id': 'horizontal', 'name': 'Horizontal'},
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
          height: 50,
          color: Colors.grey.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildLineHeightMenu(context),
                Container(height: 24, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                _buildFontSizeMenu(context),
                const SizedBox(width: 8),
                _buildFontFamilyMenu(context),
                Container(height: 24, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                _buildActionButtons(context),
              ],
            ),
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
          {'name': 'BundledRoboto', 'label': 'Roboto'},
          {'name': 'BundledPoppins', 'label': 'Poppins'},
          {'name': 'BundledGaramond', 'label': 'Garamond'},
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
          {'name': 'Source Sans 3', 'label': 'Trebuchet'},
        ].map<PopupMenuEntry<String>>((f) {
          if (f is PopupMenuEntry<String>) return f;
          final map = f as Map<String, String>;
          return _buildFontItem(map['name']!, map['label']!, widget.data.fontFamily);
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.file_download, size: 20, color: Colors.blue),
          tooltip: 'Download CV',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            final bytes = await PDFService.generateCV(_previewData);
            final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'Untitled_CV';
            await Printing.sharePdf(bytes: bytes, filename: '$name.pdf');

          },
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.print, size: 20, color: Colors.blueGrey),
          tooltip: 'Print CV',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            final bytes = await PDFService.generateCV(_previewData);
            final name = _previewData.pdfFileName.isNotEmpty ? _previewData.pdfFileName : 'Untitled_CV';
            await Printing.layoutPdf(onLayout: (format) => bytes, name: name);

          },
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.fullscreen, size: 20, color: Colors.blueGrey),
          tooltip: 'Full Screen',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenPreview(data: widget.data),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.palette, size: 20, color: Colors.indigo),
          tooltip: 'Title Color',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _showColorPicker(context),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            icon: Icon(
              _showTemplateSelector ? Icons.keyboard_arrow_down : Icons.view_carousel, 
              size: 18, 
              color: _showTemplateSelector ? Colors.blue : Colors.blueGrey
            ),
            label: Text(
              'Templates', 
              style: TextStyle(
                color: _showTemplateSelector ? Colors.blue : Colors.blueGrey,
                fontWeight: FontWeight.bold
              )
            ),
            onPressed: () {
              setState(() {
                _showTemplateSelector = !_showTemplateSelector;
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: _showTemplateSelector ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          Container(height: 16, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 18, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                _maxPageWidth = (_maxPageWidth - 100).clamp(300.0, 1500.0);
              });
            },
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.blue.shade400,
                thumbColor: Colors.blue.shade600,
              ),
              child: Slider(
                value: _maxPageWidth,
                min: 300,
                max: 1500,
                onChanged: (val) {
                  setState(() {
                    _maxPageWidth = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 18, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                _maxPageWidth = (_maxPageWidth + 100).clamp(300.0, 1500.0);
              });
            },
          ),
          Container(height: 16, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Text(
            '${((_maxPageWidth / 550) * 100).round()}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => setState(() => _maxPageWidth = 550.0),
            child: const Text('Reset', style: TextStyle(fontSize: 10, color: Colors.blue)),
          ),
        ],
      ),
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
                            child: Center(
                              // Placeholder icon until we generate images
                              child: Icon(
                                Icons.text_snippet,
                                color: isSelected ? Colors.blue : Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
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
    if (value == 'Roboto') family = 'BundledRoboto';
    if (value == 'Poppins') family = 'BundledPoppins';
    if (value == 'EBGaramond') family = 'BundledGaramond';
    if (value == 'Tinos') family = 'BundledTinos';

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
