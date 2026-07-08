// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../theme/kythera_theme.dart';
import '../widgets/kythera_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Card ──────────────────────────────────────────────
          _HeroCard(onNavigate: onNavigate),
          const SizedBox(height: 20),

          // ── Stats ──────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              StatCard(
                value: '1,247',
                label: 'Foto Di-enhance',
                delta: '+12%',
                icon: Icons.image_outlined,
                iconColor: KColor.accent,
              ),
              StatCard(
                value: '856',
                label: 'Video Dikonversi',
                delta: '+8%',
                icon: Icons.swap_horiz_rounded,
                iconColor: KColor.accent2,
              ),
              StatCard(
                value: '432',
                label: 'Video Dikompres',
                delta: '+24%',
                icon: Icons.compress_rounded,
                iconColor: KColor.accent3,
              ),
              StatCard(
                value: '128',
                label: 'Video Dipatch',
                delta: '+3%',
                icon: Icons.edit_outlined,
                iconColor: KColor.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Quick Tools ────────────────────────────────────────────
          const SectionHeader(
            title: 'Tools Cepat',
            icon: Icons.bolt,
            iconColor: KColor.accent,
          ),
          const SizedBox(height: 14),
          _ToolGrid(onNavigate: onNavigate),
          const SizedBox(height: 24),

          // ── Recent Activity ────────────────────────────────────────
          GlassCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aktivitas Terbaru',
                        style: TextStyle(
                            color: KColor.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    TextButton(
                      onPressed: () => onNavigate(4),
                      child: const Text('Lihat Semua',
                          style: TextStyle(color: KColor.accent, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ActivityItem(
                  icon: Icons.image_outlined,
                  iconColor: KColor.accent,
                  title: 'Enhance foto_wedding.jpg',
                  subtitle: 'Photo Enhance · 4x Upscale',
                  time: '2m lalu',
                ),
                _ActivityItem(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: KColor.accent2,
                  title: 'Convert gameplay.mov to .mp4',
                  subtitle: 'Converter · H.264 / 1080p',
                  time: '15m lalu',
                ),
                _ActivityItem(
                  icon: Icons.compress_rounded,
                  iconColor: KColor.accent3,
                  title: 'Compress tutorial.mp4',
                  subtitle: 'Compress · 85% size reduction',
                  time: '1j lalu',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final void Function(int) onNavigate;
  const _HeroCard({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KColor.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KColor.border, width: 1),
        boxShadow: [
          BoxShadow(
              color: KColor.accent.withOpacity(0.06),
              blurRadius: 40,
              spreadRadius: -5),
          BoxShadow(
              color: KColor.accent2.withOpacity(0.04),
              blurRadius: 40,
              spreadRadius: -5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KBadge(label: 'PRO', color: KColor.accent),
              const SizedBox(width: 10),
              const Text('Selamat datang kembali',
                  style: TextStyle(color: KColor.text3, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Kythera Tools',
            style: TextStyle(
                color: KColor.text, fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Platform all-in-one untuk enhance foto, convert, compress, dan patch video. Dibangun dengan performa tinggi untuk hasil maksimal.',
            style: TextStyle(color: KColor.text2, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Mulai Proses',
                  icon: Icons.bolt,
                  onTap: () => onNavigate(1), // ke Converter
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: KColor.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Dokumentasi',
                      style: TextStyle(color: KColor.text2, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tool Grid ────────────────────────────────────────────────────────────────
class _ToolGrid extends StatelessWidget {
  final void Function(int) onNavigate;
  const _ToolGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolInfo('Photo Enhance / HD', 'Upscale foto hingga 4x dengan AI.',
          Icons.image_outlined, KColor.accent, 0),
      _ToolInfo('Converter Video', 'Konversi antar format: MP4, AVI, MKV, MOV...',
          Icons.swap_horiz_rounded, KColor.accent2, 1),
      _ToolInfo('Compress Video', 'Kurangi ukuran video hingga 90%.',
          Icons.compress_rounded, KColor.accent3, 2),
      _ToolInfo('Patch Video', 'Patch metadata, inject watermark...',
          Icons.edit_outlined, KColor.orange, 3),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: tools
          .map((t) => _ToolCard(
                tool: t,
                onTap: () => onNavigate(t.navIndex),
              ))
          .toList(),
    );
  }
}

class _ToolInfo {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final int navIndex;
  const _ToolInfo(this.title, this.desc, this.icon, this.color, this.navIndex);
}

class _ToolCard extends StatefulWidget {
  final _ToolInfo tool;
  final VoidCallback onTap;
  const _ToolCard({required this.tool, required this.onTap});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp: (_) => setState(() => _hover = false),
      onTapCancel: () => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hover
              ? widget.tool.color.withOpacity(0.05)
              : const Color(0xFF111111).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hover
                ? widget.tool.color.withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.tool.color.withOpacity(0.08),
                    blurRadius: 20,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.tool.color.withOpacity(0.25),
                    widget.tool.color.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.tool.icon, color: widget.tool.color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(widget.tool.title,
                style: const TextStyle(
                    color: KColor.text, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Text(widget.tool.desc,
                style: const TextStyle(color: KColor.text3, fontSize: 11, height: 1.4),
                maxLines: 3),
            const Spacer(),
            Row(
              children: [
                Text('Buka Tool',
                    style: TextStyle(
                        color: widget.tool.color, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: widget.tool.color, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Item ────────────────────────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: KColor.text, fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: const TextStyle(color: KColor.text3, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time,
                  style: const TextStyle(
                      color: KColor.text3, fontSize: 10, fontFamily: 'monospace')),
              const SizedBox(height: 4),
              const KBadge(label: 'Done', color: KColor.accent3),
            ],
          ),
        ],
      ),
    );
  }
}
