// lib/screens/patch_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/kythera_theme.dart';
import '../widgets/kythera_widgets.dart';
import '../services/ffmpeg_service.dart';
import '../services/gallery_service.dart';

enum PatchType { metadata, watermark, streamPatch, subtitle }

class PatchScreen extends StatefulWidget {
  const PatchScreen({super.key});

  @override
  State<PatchScreen> createState() => _PatchScreenState();
}

class _PatchScreenState extends State<PatchScreen> {
  String?   _inputPath;
  String?   _fileName;
  String?   _fileSize;
  PatchType _patchType      = PatchType.metadata;
  bool      _preserveOrig   = true;
  bool      _backupBefore   = true;
  bool      _verifyIntegrity= false;
  bool      _isProcessing   = false;

  // Metadata fields
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _yearCtrl   = TextEditingController(text: '2026');

  // Watermark field
  final _wmCtrl = TextEditingController(text: 'D4nzxml');

  final _ffmpeg = FfmpegService();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _authorCtrl.dispose();
    _yearCtrl.dispose();
    _wmCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _applyPatch() async {
    if (_inputPath == null) {
      _toast('Pilih video dulu Kang!');
      return;
    }
    setState(() => _isProcessing = true);

    FfmpegResult result;
    if (_patchType == PatchType.metadata) {
      result = await _ffmpeg.patchMetadata(
        inputPath  : _inputPath!,
        title      : _titleCtrl.text,
        description: _descCtrl.text,
        author     : _authorCtrl.text,
        year       : _yearCtrl.text,
      );
    } else if (_patchType == PatchType.watermark) {
      result = await _ffmpeg.patchWatermark(
        inputPath     : _inputPath!,
        watermarkText : _wmCtrl.text,
      );
    } else {
      setState(() => _isProcessing = false);
      _toast('Fitur ini belum diimplementasi.');
      return;
    }

    setState(() => _isProcessing = false);

    if (result.success) {
      final saved = await GalleryService.saveVideo(result.outputPath);
      _toast(saved ? 'PATCH SUKSES! Tersimpan di Galeri/Kythera 🎉' : 'Selesai, gagal simpan galeri.');
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
              Row(
                children: [
                  const Text('Patch Video',
                      style: TextStyle(
                          color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 10),
                  const KBadge(label: 'BETA', color: KColor.orange),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Modifikasi metadata, inject watermark, atau patch stream video.',
                  style: TextStyle(color: KColor.text2, fontSize: 13)),
              const SizedBox(height: 20),

              // ── Drop zone + patch controls ──────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropZone(
                      onTap: _pickVideo,
                      title: 'Pilih video target',
                      subtitle: 'MP4, MKV, AVI, MOV, WEBM',
                      icon: Icons.cloud_upload_outlined,
                      accentColor: KColor.orange,
                      selectedFileName: _fileName,
                      selectedFileSize: _fileSize,
                    ),
                    const SizedBox(height: 20),

                    // Patch type selector
                    const FieldLabel('Patch Type'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3.2,
                      children: [
                        _PatchTypeBtn(
                          label: 'Metadata',
                          icon: Icons.label_outline,
                          isActive: _patchType == PatchType.metadata,
                          onTap: () => setState(() => _patchType = PatchType.metadata),
                          activeColor: KColor.orange,
                        ),
                        _PatchTypeBtn(
                          label: 'Watermark',
                          icon: Icons.add_circle_outline,
                          isActive: _patchType == PatchType.watermark,
                          onTap: () => setState(() => _patchType = PatchType.watermark),
                          activeColor: KColor.orange,
                        ),
                        _PatchTypeBtn(
                          label: 'Stream Patch',
                          icon: Icons.link_outlined,
                          isActive: _patchType == PatchType.streamPatch,
                          onTap: () => setState(() => _patchType = PatchType.streamPatch),
                          activeColor: KColor.orange,
                        ),
                        _PatchTypeBtn(
                          label: 'Subtitle',
                          icon: Icons.subtitles_outlined,
                          isActive: _patchType == PatchType.subtitle,
                          onTap: () => setState(() => _patchType = PatchType.subtitle),
                          activeColor: KColor.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dynamic form by patch type
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _patchType == PatchType.metadata
                          ? _MetadataForm(
                              key: const ValueKey('meta'),
                              titleCtrl : _titleCtrl,
                              descCtrl  : _descCtrl,
                              authorCtrl: _authorCtrl,
                              yearCtrl  : _yearCtrl,
                            )
                          : _patchType == PatchType.watermark
                              ? _WatermarkForm(
                                  key: const ValueKey('wm'),
                                  wmCtrl: _wmCtrl,
                                )
                              : Container(
                                  key: const ValueKey('na'),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: KColor.surface2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: KColor.border),
                                  ),
                                  child: const Text(
                                    'Fitur ini sedang dalam pengembangan...',
                                    style: TextStyle(
                                        color: KColor.text3, fontSize: 12),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Advanced options ────────────────────────────────────
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Advanced Options',
                        style: TextStyle(
                            color: KColor.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 14),
                    ToggleRow(
                      title: 'Preserve Original',
                      subtitle: 'Simpan file asli',
                      value: _preserveOrig,
                      onChanged: (v) => setState(() => _preserveOrig = v),
                    ),
                    const SizedBox(height: 12),
                    ToggleRow(
                      title: 'Backup Before Patch',
                      subtitle: 'Buat backup otomatis',
                      value: _backupBefore,
                      onChanged: (v) => setState(() => _backupBefore = v),
                    ),
                    const SizedBox(height: 12),
                    ToggleRow(
                      title: 'Verify Integrity',
                      subtitle: 'Cek integritas setelah patch',
                      value: _verifyIntegrity,
                      onChanged: (v) => setState(() => _verifyIntegrity = v),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KColor.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: KColor.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: KColor.orange.withOpacity(0.8), size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Pastikan backup sebelum melanjutkan. Patching memodifikasi container tanpa re-encode.',
                              style: TextStyle(
                                  color: KColor.text3,
                                  fontSize: 11,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                label: 'Apply Patch',
                icon: Icons.edit_outlined,
                onTap: _isProcessing ? null : _applyPatch,
                startColor: KColor.orange,
                endColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_isProcessing)
          const Positioned.fill(
            child: LoadingOverlay(
              isVisible: true,
              message: 'Patching Video...',
              subMessage: 'Memodifikasi metadata container...\nProses cepat, hampir selesai!',
            ),
          ),
      ],
    );
  }
}

// ─── Patch Type Button ────────────────────────────────────────────────────────
class _PatchTypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const _PatchTypeBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isActive ? activeColor.withOpacity(0.5) : KColor.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? activeColor : KColor.text2, size: 15),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isActive ? activeColor : KColor.text2,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Metadata Form ────────────────────────────────────────────────────────────
class _MetadataForm extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController authorCtrl;
  final TextEditingController yearCtrl;

  const _MetadataForm({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
    required this.authorCtrl,
    required this.yearCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Title Metadata'),
        TextField(
          controller: titleCtrl,
          style: const TextStyle(color: KColor.text, fontSize: 13),
          decoration: const InputDecoration(hintText: 'Judul video'),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Description'),
        TextField(
          controller: descCtrl,
          maxLines: 3,
          style: const TextStyle(color: KColor.text, fontSize: 13),
          decoration: const InputDecoration(hintText: 'Deskripsi video'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Author'),
                  TextField(
                    controller: authorCtrl,
                    style: const TextStyle(color: KColor.text, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'Nama author'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Year'),
                  TextField(
                    controller: yearCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: KColor.text, fontSize: 13),
                    decoration: const InputDecoration(hintText: '2026'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Watermark Form ───────────────────────────────────────────────────────────
class _WatermarkForm extends StatelessWidget {
  final TextEditingController wmCtrl;
  const _WatermarkForm({super.key, required this.wmCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Teks Watermark'),
        TextField(
          controller: wmCtrl,
          style: const TextStyle(color: KColor.text, fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: D4nzxml © 2026'),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KColor.accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KColor.accent.withOpacity(0.15)),
          ),
          child: const Text(
            'Watermark teks akan muncul di pojok kanan bawah video. Posisi & ukuran otomatis.',
            style: TextStyle(color: KColor.text3, fontSize: 11, height: 1.4),
          ),
        ),
      ],
    );
  }
}
