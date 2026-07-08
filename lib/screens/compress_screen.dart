// lib/screens/compress_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/kythera_theme.dart';
import '../widgets/kythera_widgets.dart';
import '../services/ffmpeg_service.dart';
import '../services/gallery_service.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  String? _inputPath;
  String? _fileName;
  String? _fileSize;
  int     _compressPercent = 60;
  bool    _audioCompress   = true;
  bool    _removeMetadata  = false;
  bool    _twoPass         = true;
  bool    _isProcessing    = false;

  final _ffmpeg = FfmpegService();

  Future<void> _pickVideo() async {
    await Permission.videos.request();
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    setState(() {
      _inputPath = file.path;
      _fileName  = file.name;
      _fileSize  = FfmpegService.formatSize(file.size ?? 0);
    });
  }

  Future<void> _compress() async {
    if (_inputPath == null) {
      _toast('Pilih video dulu Kang!');
      return;
    }
    setState(() => _isProcessing = true);

    final result = await _ffmpeg.compressVideo(
      inputPath      : _inputPath!,
      compressPercent: _compressPercent,
      compressAudio  : _audioCompress,
      removeMetadata : _removeMetadata,
      twoPass        : _twoPass,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Compress Video',
                  style: TextStyle(
                      color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Kurangi ukuran file video dengan algoritma kompresi cerdas.',
                  style: TextStyle(color: KColor.text2, fontSize: 13)),
              const SizedBox(height: 20),

              // ── Drop zone ───────────────────────────────────────────
              GlassCard(
                child: DropZone(
                  onTap: _pickVideo,
                  title: 'Drop video untuk compress',
                  subtitle: 'Maksimal file 2GB per proses',
                  icon: Icons.compress_rounded,
                  accentColor: KColor.accent3,
                  selectedFileName: _fileName,
                  selectedFileSize: _fileSize,
                ),
              ),
              const SizedBox(height: 14),

              // ── Target kompresi ─────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Kompresi',
                        style: TextStyle(
                            color: KColor.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _CompressOption(
                          percent: 30,
                          label: 'Light',
                          sub: 'Kualitas hampir sama',
                          color: KColor.accent3,
                          isActive: _compressPercent == 30,
                          onTap: () => setState(() => _compressPercent = 30),
                        ),
                        const SizedBox(width: 10),
                        _CompressOption(
                          percent: 60,
                          label: 'Balanced',
                          sub: 'Recommended',
                          color: KColor.accent3,
                          isActive: _compressPercent == 60,
                          onTap: () => setState(() => _compressPercent = 60),
                        ),
                        const SizedBox(width: 10),
                        _CompressOption(
                          percent: 85,
                          label: 'Aggressive',
                          sub: 'Ukuran minimal',
                          color: KColor.orange,
                          isActive: _compressPercent == 85,
                          onTap: () => setState(() => _compressPercent = 85),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: KColor.border, height: 1),
                    const SizedBox(height: 16),
                    ToggleRow(
                      title: 'Audio Compression',
                      subtitle: 'Kompres juga track audio',
                      value: _audioCompress,
                      onChanged: (v) => setState(() => _audioCompress = v),
                    ),
                    const SizedBox(height: 14),
                    ToggleRow(
                      title: 'Remove Metadata',
                      subtitle: 'Hapus data EXIF dan metadata',
                      value: _removeMetadata,
                      onChanged: (v) => setState(() => _removeMetadata = v),
                    ),
                    const SizedBox(height: 14),
                    ToggleRow(
                      title: 'Two-Pass Encoding',
                      subtitle: 'Kualitas lebih baik, proses lebih lama',
                      value: _twoPass,
                      onChanged: (v) => setState(() => _twoPass = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Estimasi output bar ─────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimasi Output',
                            style: TextStyle(
                                color: KColor.text,
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        Text(
                          _compressPercent == 30
                              ? 'Pengurangan 30%'
                              : _compressPercent == 60
                                  ? 'Pengurangan 60%'
                                  : 'Pengurangan 85%',
                          style: const TextStyle(
                              color: KColor.accent3, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1 - (_compressPercent / 100),
                        minHeight: 6,
                        backgroundColor: KColor.surface2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            KColor.accent3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('0 MB',
                            style: TextStyle(color: KColor.text3, fontSize: 10)),
                        Text(
                          '${_compressPercent}% size reduction',
                          style: const TextStyle(
                              color: KColor.accent3,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                        const Text('Original',
                            style: TextStyle(color: KColor.text3, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                label: 'Compress Video',
                icon: Icons.compress_rounded,
                onTap: _isProcessing ? null : _compress,
                startColor: KColor.accent3,
                endColor: const Color(0xFF059669),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_isProcessing)
          const Positioned.fill(
            child: LoadingOverlay(
              isVisible: true,
              message: 'Mengompresi Video...',
              subMessage: 'Two-pass encoding sedang berjalan...\nTunggu sampai proses selesai!',
            ),
          ),
      ],
    );
  }
}

// ─── Compress Option Card ─────────────────────────────────────────────────────
class _CompressOption extends StatelessWidget {
  final int percent;
  final String label;
  final String sub;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _CompressOption({
    required this.percent,
    required this.label,
    required this.sub,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? color : KColor.border, width: 1.5),
          ),
          child: Column(
            children: [
              Text('$percent%',
                  style: TextStyle(
                      color: color, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: KColor.text3, fontSize: 10, fontWeight: FontWeight.w500)),
              Text(sub,
                  style: const TextStyle(color: KColor.text3, fontSize: 9),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
