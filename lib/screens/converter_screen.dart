// lib/screens/converter_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/kythera_theme.dart';
import '../widgets/kythera_widgets.dart';
import '../services/ffmpeg_service.dart';
import '../services/gallery_service.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  String? _inputPath;
  String? _fileName;
  String? _fileSize;
  String _selectedFormat = 'MP4';
  String _selectedCodec  = 'libx264';
  String _selectedRes    = 'original';
  double _bitrateM       = 8;
  bool   _isProcessing   = false;

  final _ffmpeg = FfmpegService();

  static const _formats = ['MP4', 'MKV', 'AVI', 'WEBM', 'MOV', 'GIF'];

  static const _codecs = {
    'H.264 (AVC) — Compatible' : 'libx264',
    'H.265 (HEVC) — Efficient' : 'libx265',
    'AV1 — Next Gen'           : 'libaom-av1',
    'VP9 — Web Optimized'      : 'libvpx-vp9',
  };

  static const _resolutions = {
    'Original'          : 'original',
    '4K UHD (3840x2160)': '3840:2160',
    '1440p (2560x1440)' : '2560:1440',
    '1080p (1920x1080)' : '1920:1080',
    '720p (1280x720)'   : '1280:720',
    '480p (854x480)'    : '854:480',
  };

  // ── Pick file ──────────────────────────────────────────────────────────────
  Future<void> _pickVideo() async {
    final perm = await Permission.videos.request();
    if (!perm.isGranted) {
      await Permission.storage.request();
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() {
      _inputPath = file.path;
      _fileName  = file.name;
      _fileSize  = FfmpegService.formatSize(file.size ?? 0);
    });
  }

  // ── Run conversion ─────────────────────────────────────────────────────────
  Future<void> _convert() async {
    if (_inputPath == null) {
      _toast('Pilih video dulu Kang!');
      return;
    }
    setState(() => _isProcessing = true);

    final result = await _ffmpeg.convertVideo(
      inputPath    : _inputPath!,
      targetFormat : _selectedFormat.toLowerCase(),
      bitrateM     : _bitrateM.round(),
      codec        : _selectedCodec,
      resolution   : _resolutions.values.toList()[
        _resolutions.values.toList().indexOf(_selectedRes)],
    );

    setState(() => _isProcessing = false);

    if (result.success) {
      final saved = await GalleryService.saveVideo(result.outputPath);
      _toast(saved
          ? 'SUKSES! Video tersimpan di Galeri/Kythera 🎉'
          : 'Selesai, tapi gagal simpan ke galeri.');
    } else {
      _toast('ERROR FFmpeg: ${result.errorMessage}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: KColor.text)),
        backgroundColor: KColor.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Converter Video',
                  style: TextStyle(
                      color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Konversi video ke berbagai format dengan kontrol kualitas penuh.',
                  style: TextStyle(color: KColor.text2, fontSize: 13)),
              const SizedBox(height: 20),

              // ── Input Card ──────────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StepBadge('1', KColor.accent),
                        const SizedBox(width: 10),
                        const Text('Input Video',
                            style: TextStyle(
                                color: KColor.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropZone(
                      onTap: _pickVideo,
                      title: 'Drop video atau klik upload',
                      subtitle: 'MP4, AVI, MKV, MOV, WEBM, FLV',
                      icon: Icons.cloud_upload_outlined,
                      accentColor: KColor.accent,
                      selectedFileName: _fileName,
                      selectedFileSize: _fileSize,
                    ),
                    if (_inputPath != null) ...[
                      const SizedBox(height: 16),
                      const Divider(color: KColor.border, height: 1),
                      const SizedBox(height: 12),
                      InfoRow(
                          label: 'Format Asli',
                          value: '.${_inputPath!.split('.').last}'),
                      InfoRow(label: 'Size', value: _fileSize ?? '-'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Output Settings Card ────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StepBadge('2', KColor.accent2),
                        const SizedBox(width: 10),
                        const Text('Output Settings',
                            style: TextStyle(
                                color: KColor.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Format tabs
                    const FieldLabel('Format Output'),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.4,
                      children: _formats
                          .map((f) => FormatTabButton(
                                label: f,
                                isActive: _selectedFormat == f,
                                onTap: () => setState(() => _selectedFormat = f),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Codec dropdown
                    const FieldLabel('Codec'),
                    _KDropdown(
                      items: _codecs.keys.toList(),
                      value: _codecs.keys.firstWhere(
                          (k) => _codecs[k] == _selectedCodec,
                          orElse: () => _codecs.keys.first),
                      onChanged: (v) =>
                          setState(() => _selectedCodec = _codecs[v]!),
                    ),
                    const SizedBox(height: 16),

                    // Resolution dropdown
                    const FieldLabel('Resolution'),
                    _KDropdown(
                      items: _resolutions.keys.toList(),
                      value: _resolutions.keys.firstWhere(
                          (k) => _resolutions[k] == _selectedRes,
                          orElse: () => _resolutions.keys.first),
                      onChanged: (v) =>
                          setState(() => _selectedRes = _resolutions[v]!),
                    ),
                    const SizedBox(height: 16),

                    // Bitrate slider
                    const FieldLabel('Bitrate'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _bitrateM,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            onChanged: (v) => setState(() => _bitrateM = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '${_bitrateM.round()} Mbps',
                            style: const TextStyle(
                                color: KColor.text2,
                                fontFamily: 'monospace',
                                fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Convert Button ──────────────────────────────────────
              PrimaryButton(
                label: 'Konversi Sekarang',
                icon: Icons.swap_horiz_rounded,
                onTap: _isProcessing ? null : _convert,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── Loading overlay ─────────────────────────────────────────
        if (_isProcessing)
          const Positioned.fill(
            child: LoadingOverlay(isVisible: true),
          ),
      ],
    );
  }
}

// ─── Step Badge ───────────────────────────────────────────────────────────────
class _StepBadge extends StatelessWidget {
  final String number;
  final Color color;
  const _StepBadge(this.number, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(number,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Dropdown ─────────────────────────────────────────────────────────────────
class _KDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  const _KDropdown(
      {required this.items, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: KColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KColor.border),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: KColor.surface2,
        style: const TextStyle(color: KColor.text2, fontSize: 13),
        icon: const Icon(Icons.keyboard_arrow_down, color: KColor.text3, size: 18),
        items: items
            .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i,
                      style:
                          const TextStyle(color: KColor.text2, fontSize: 13)),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
