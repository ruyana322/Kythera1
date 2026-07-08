// lib/widgets/kythera_widgets.dart
import 'package:flutter/material.dart';
import '../theme/kythera_theme.dart';

// ─── Glass Card ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.85),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ─── Primary Button (cyan gradient) ──────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color startColor;
  final Color endColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.startColor = KColor.accent,
    this.endColor = const Color(0xFF0891B2),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null
              ? [BoxShadow(color: startColor.withOpacity(0.25), blurRadius: 20, spreadRadius: -4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drop Zone ────────────────────────────────────────────────────────────────
class DropZone extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? selectedFileName;
  final String? selectedFileSize;

  const DropZone({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accentColor = KColor.accent,
    this.selectedFileName,
    this.selectedFileSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: KColor.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedFileName != null
                ? accentColor.withOpacity(0.5)
                : KColor.border2,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(height: 12),
            if (selectedFileName != null) ...[
              Text(
                selectedFileName!,
                style: const TextStyle(
                    color: KColor.text, fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                selectedFileSize ?? '',
                style: const TextStyle(color: KColor.accent, fontSize: 11),
              ),
            ] else ...[
              Text(
                title,
                style: const TextStyle(
                    color: KColor.text, fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: KColor.text3, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Format Tab Button ────────────────────────────────────────────────────────
class FormatTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FormatTabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? KColor.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? KColor.accent.withOpacity(0.5) : KColor.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? KColor.accent : KColor.text2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Toggle Row ───────────────────────────────────────────────────────────────
class ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: KColor.text, fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: KColor.text3, fontSize: 11)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String delta;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.delta,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(delta,
                  style: TextStyle(
                      color: iconColor, fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: KColor.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: KColor.text3, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const SectionHeader({super.key, required this.title, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? KColor.accent, size: 18),
          const SizedBox(width: 8),
        ],
        Text(title,
            style: const TextStyle(
                color: KColor.text, fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────
class KBadge extends StatelessWidget {
  final String label;
  final Color color;

  const KBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 0.5),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: KColor.text3, fontSize: 11)),
      );
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: KColor.text3, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: KColor.text2, fontFamily: 'monospace', fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Loading Overlay ──────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;
  final String subMessage;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    this.message = 'Memproses Video...',
    this.subMessage = 'Mesin FFmpeg sedang bekerja...\nTunggu sampai proses selesai!',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          borderColor: KColor.accent.withOpacity(0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: KColor.accent,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(message,
                  style: const TextStyle(
                      color: KColor.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                subMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: KColor.text3, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
