// lib/screens/photo_enhance_screen.dart
import 'package:flutter/material.dart';
import '../theme/kythera_theme.dart';
import '../widgets/kythera_widgets.dart';

class PhotoEnhanceScreen extends StatefulWidget {
  const PhotoEnhanceScreen({super.key});

  @override
  State<PhotoEnhanceScreen> createState() => _PhotoEnhanceScreenState();
}

class _PhotoEnhanceScreenState extends State<PhotoEnhanceScreen> {
  int    _scaleFactor     = 4;
  double _denoiseLevel    = 50;
  bool   _faceEnhancement = true;
  String _selectedModel   = 'Kythera Real-ESRGAN (Recommended)';

  static const _models = [
    'Kythera Real-ESRGAN (Recommended)',
    'Waifu2x (Anime/Art)',
    'BSRGAN (General)',
    'SRFormer (Ultra HD)',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo Enhance / HD',
              style: TextStyle(
                  color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
              'Upscale foto dengan AI. Dukungan hingga 4x resolusi dengan pemulihan detail otomatis.',
              style: TextStyle(color: KColor.text2, fontSize: 13)),
          const SizedBox(height: 20),

          // Drop zone
          DropZone(
            onTap: () {},
            title: 'Drop foto di sini atau klik untuk upload',
            subtitle: 'Mendukung JPG, PNG, WEBP, BMP · Max 50MB',
            icon: Icons.image_outlined,
            accentColor: KColor.accent,
          ),
          const SizedBox(height: 16),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Pengaturan Enhance',
                  icon: Icons.settings_outlined,
                  iconColor: KColor.accent,
                ),
                const SizedBox(height: 20),

                // Scale factor
                const FieldLabel('Scale Factor'),
                Row(
                  children: [2, 4, 8].map((f) {
                    final active = _scaleFactor == f;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: f != 8 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _scaleFactor = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: active
                                  ? KColor.accent.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: active
                                      ? KColor.accent
                                      : KColor.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${f}x',
                              style: TextStyle(
                                  color: active ? KColor.accent : KColor.text2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // AI Model dropdown
                const FieldLabel('Model AI'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: KColor.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KColor.border),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedModel,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: KColor.surface2,
                    style:
                        const TextStyle(color: KColor.text2, fontSize: 13),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: KColor.text3, size: 18),
                    items: _models
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m,
                                  style: const TextStyle(
                                      color: KColor.text2, fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedModel = v!),
                  ),
                ),
                const SizedBox(height: 18),

                // Denoise
                const FieldLabel('Denoise Level'),
                Slider(
                  value: _denoiseLevel,
                  min: 0,
                  max: 100,
                  onChanged: (v) => setState(() => _denoiseLevel = v),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('None',
                        style: TextStyle(color: KColor.text3, fontSize: 10)),
                    Text('Medium',
                        style: TextStyle(color: KColor.text3, fontSize: 10)),
                    Text('Max',
                        style: TextStyle(color: KColor.text3, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 18),

                // Face enhancement toggle
                ToggleRow(
                  title: 'Face Enhancement',
                  subtitle: 'Deteksi dan perbaiki wajah otomatis',
                  value: _faceEnhancement,
                  onChanged: (v) => setState(() => _faceEnhancement = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const PrimaryButton(
            label: 'Mulai Enhance',
            icon: Icons.bolt,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _items = [
    _HistItem(
        'foto_wedding.jpg',
        'Photo Enhance · 4x Upscale',
        '2m lalu',
        Icons.image_outlined,
        KColor.accent),
    _HistItem(
        'gameplay.mov → .mp4',
        'Converter · H.264 / 1080p',
        '15m lalu',
        Icons.swap_horiz_rounded,
        KColor.accent2),
    _HistItem(
        'tutorial.mp4',
        'Compress · 85% size reduction',
        '1j lalu',
        Icons.compress_rounded,
        KColor.accent3),
    _HistItem(
        'vlog_2026.mp4',
        'Patch · Metadata update',
        '3j lalu',
        Icons.edit_outlined,
        KColor.orange),
    _HistItem(
        'short_vid.mp4',
        'Converter · WEBM / VP9',
        '1h lalu',
        Icons.swap_horiz_rounded,
        KColor.accent2),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat',
              style: TextStyle(
                  color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Semua aktivitas proses yang telah dilakukan.',
              style: TextStyle(color: KColor.text2, fontSize: 13)),
          const SizedBox(height: 20),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Filter tabs
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: ['Semua', 'Enhance', 'Convert', 'Compress']
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: e.key == 0
                                      ? KColor.accent.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: e.key == 0
                                        ? KColor.accent.withOpacity(0.4)
                                        : KColor.border,
                                  ),
                                ),
                                child: Text(e.value,
                                    style: TextStyle(
                                        color: e.key == 0
                                            ? KColor.accent
                                            : KColor.text2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(color: KColor.border, height: 1),
                ..._items.map((item) => Column(
                      children: [
                        _HistoryTile(item: item),
                        const Divider(
                            color: KColor.border, height: 1, indent: 64),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HistItem {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  const _HistItem(
      this.title, this.subtitle, this.time, this.icon, this.color);
}

class _HistoryTile extends StatelessWidget {
  final _HistItem item;
  const _HistoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: KColor.text, fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(item.subtitle,
                    style: const TextStyle(color: KColor.text3, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.time,
                  style: const TextStyle(
                      color: KColor.text3,
                      fontSize: 10,
                      fontFamily: 'monospace')),
              const SizedBox(height: 4),
              const KBadge(label: 'Done', color: KColor.accent3),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hwAccel    = true;
  bool _autoSave   = true;
  bool _notif      = true;
  bool _darkMode   = true;
  bool _analytics  = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan',
              style: TextStyle(
                  color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Konfigurasi aplikasi dan preferensi pemrosesan.',
              style: TextStyle(color: KColor.text2, fontSize: 13)),
          const SizedBox(height: 20),

          _SettingsGroup(
            title: 'Pemrosesan',
            icon: Icons.memory_outlined,
            children: [
              ToggleRow(
                title: 'Hardware Acceleration',
                subtitle: 'Gunakan GPU untuk proses lebih cepat',
                value: _hwAccel,
                onChanged: (v) => setState(() => _hwAccel = v),
              ),
              const SizedBox(height: 14),
              ToggleRow(
                title: 'Auto Save ke Galeri',
                subtitle: 'Simpan otomatis setelah proses selesai',
                value: _autoSave,
                onChanged: (v) => setState(() => _autoSave = v),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _SettingsGroup(
            title: 'Tampilan',
            icon: Icons.palette_outlined,
            children: [
              ToggleRow(
                title: 'Dark Mode',
                subtitle: 'Tema gelap (default)',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              const SizedBox(height: 14),
              ToggleRow(
                title: 'Notifikasi',
                subtitle: 'Notifikasi saat proses selesai',
                value: _notif,
                onChanged: (v) => setState(() => _notif = v),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _SettingsGroup(
            title: 'Privasi',
            icon: Icons.shield_outlined,
            children: [
              ToggleRow(
                title: 'Analytics',
                subtitle: 'Kirim data anonim untuk perbaikan app',
                value: _analytics,
                onChanged: (v) => setState(() => _analytics = v),
              ),
            ],
          ),
          const SizedBox(height: 14),

          GlassCard(
            child: Column(
              children: [
                _InfoTile(label: 'Versi Aplikasi', value: '1.0.0'),
                const Divider(color: KColor.border, height: 20),
                _InfoTile(label: 'FFmpeg Version', value: '6.x (min-gpl)'),
                const Divider(color: KColor.border, height: 20),
                _InfoTile(label: 'Developer', value: 'D4nzxml / JGC'),
                const Divider(color: KColor.border, height: 20),
                _InfoTile(label: 'Build', value: 'Flutter · Release'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsGroup(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: KColor.accent, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: KColor.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: KColor.text2, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: KColor.text3,
                fontFamily: 'monospace',
                fontSize: 12)),
      ],
    );
  }
}
