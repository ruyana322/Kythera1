// lib/theme/kythera_theme.dart
import 'package:flutter/material.dart';

// ─── Color Tokens (mirrored dari tailwind config HTML asli) ───────────────────
class KColor {
  static const bg        = Color(0xFF050505);
  static const surface   = Color(0xFF0A0A0A);
  static const surface2  = Color(0xFF111111);
  static const surface3  = Color(0xFF1A1A1A);
  static const border    = Color(0xFF1F1F1F);
  static const border2   = Color(0xFF2A2A2A);
  static const accent    = Color(0xFF00D4FF); // cyan
  static const accent2   = Color(0xFF7C3AED); // purple
  static const accent3   = Color(0xFF10B981); // emerald
  static const orange    = Color(0xFFF59E0B);
  static const text      = Color(0xFFE5E5E5);
  static const text2     = Color(0xFFA1A1AA);
  static const text3     = Color(0xFF71717A);
}

// ─── Glass card decoration ────────────────────────────────────────────────────
BoxDecoration glassCard({Color? border}) => BoxDecoration(
  color: const Color(0xFF111111).withOpacity(0.8),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: border ?? Colors.white.withOpacity(0.06),
    width: 1,
  ),
);

// gradient border decoration (dashboard hero card)
BoxDecoration gradientBorder() => BoxDecoration(
  color: KColor.surface2,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: Colors.transparent,
    width: 1.5,
  ),
  boxShadow: [
    BoxShadow(color: KColor.accent.withOpacity(0.08), blurRadius: 40, spreadRadius: -5),
    BoxShadow(color: KColor.accent2.withOpacity(0.06), blurRadius: 40, spreadRadius: -5),
  ],
);

// ─── Drop zone decoration ─────────────────────────────────────────────────────
BoxDecoration dropZone({Color accentColor = KColor.accent}) => BoxDecoration(
  color: KColor.surface.withOpacity(0.5),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
);

// ─── Theme Data ───────────────────────────────────────────────────────────────
ThemeData kytheraTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: KColor.bg,
  colorScheme: const ColorScheme.dark(
    primary: KColor.accent,
    secondary: KColor.accent2,
    tertiary: KColor.accent3,
    surface: KColor.surface,
    background: KColor.bg,
  ),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge : TextStyle(color: KColor.text, fontWeight: FontWeight.w800),
    titleLarge   : TextStyle(color: KColor.text, fontWeight: FontWeight.w700, fontSize: 22),
    titleMedium  : TextStyle(color: KColor.text, fontWeight: FontWeight.w600, fontSize: 16),
    bodyLarge    : TextStyle(color: KColor.text, fontSize: 14),
    bodyMedium   : TextStyle(color: KColor.text2, fontSize: 13),
    bodySmall    : TextStyle(color: KColor.text3, fontSize: 11),
    labelSmall   : TextStyle(color: KColor.text3, fontSize: 10, fontWeight: FontWeight.w500),
  ),
  dividerTheme: const DividerThemeData(color: KColor.border, thickness: 1),
  sliderTheme: SliderThemeData(
    activeTrackColor: KColor.accent,
    inactiveTrackColor: KColor.border2,
    thumbColor: KColor.accent,
    overlayColor: KColor.accent.withOpacity(0.1),
    trackHeight: 3,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((s) =>
        s.contains(MaterialState.selected) ? KColor.bg : KColor.text2),
    trackColor: MaterialStateProperty.resolveWith((s) =>
        s.contains(MaterialState.selected) ? KColor.accent : KColor.border2),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColor.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColor.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColor.accent, width: 1.5),
    ),
    hintStyle: const TextStyle(color: KColor.text3, fontSize: 13),
    labelStyle: const TextStyle(color: KColor.text3, fontSize: 12),
  ),
);
