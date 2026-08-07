// lib/core/theme/app_colors.dart
//
// Raw color VALUES only — no widgets, no logic.
// Each semantic name has a dark-mode and light-mode value.
// theme.dart wraps these into Flutter's ThemeExtension system.

import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // ── Brand (same in both modes — brand identity shouldn't shift) ──
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color accent;

  // ── Semantic ──
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // ── Disease ──
  final Color diseaseNormal;
  final Color diseaseConjunctivitis;
  final Color diseaseCataract;
  final Color diseaseUnknown;

  // ── Surfaces (these DO change between modes) ──
  final Color bg;            // scaffold background
  final Color bgSurface;     // app bar / nav bar background
  final Color card;          // card background
  final Color cardAlt;       // secondary card / input fill
  final Color border;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ── Gradients ──
  final List<Color> primaryGradient;
  final List<Color> bgGradient;
  final List<Color> cardGradient;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.diseaseNormal,
    required this.diseaseConjunctivitis,
    required this.diseaseCataract,
    required this.diseaseUnknown,
    required this.bg,
    required this.bgSurface,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryGradient,
    required this.bgGradient,
    required this.cardGradient,
  });

  // ── DARK MODE (original palette, unchanged values) ──
  static const dark = AppColors(
    primary: Color(0xFF0EA5E9),
    primaryDark: Color(0xFF0284C7),
    primaryLight: Color(0xFF38BDF8),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF06B6D4),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    diseaseNormal: Color(0xFF22C55E),
    diseaseConjunctivitis: Color(0xFFF59E0B),
    diseaseCataract: Color(0xFFEF4444),
    diseaseUnknown: Color(0xFF64748B),
    bg: Color(0xFF070B14),
    bgSurface: Color(0xFF0D1220),
    card: Color(0xFF111827),
    cardAlt: Color(0xFF1A2236),
    border: Color(0xFF1E2D40),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF475569),
    primaryGradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    bgGradient: [Color(0xFF070B14), Color(0xFF070B14)],
    cardGradient: [Color(0xFF111827), Color(0xFF1A2236)],
  );

  // ── LIGHT MODE (new palette, same brand hues, inverted surfaces) ──
  static const light = AppColors(
    primary: Color(0xFF0EA5E9),
    primaryDark: Color(0xFF0284C7),
    primaryLight: Color(0xFF38BDF8),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF06B6D4),
    success: Color(0xFF16A34A),       // slightly deeper for contrast on white
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
    diseaseNormal: Color(0xFF16A34A),
    diseaseConjunctivitis: Color(0xFFD97706),
    diseaseCataract: Color(0xFFDC2626),
    diseaseUnknown: Color(0xFF64748B),
    bg: Color(0xFFF8FAFC),            // soft off-white, not pure white
    bgSurface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    primaryGradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    bgGradient: [Color(0xFFF8FAFC), Color(0xFFF8FAFC)],
    cardGradient: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? diseaseNormal,
    Color? diseaseConjunctivitis,
    Color? diseaseCataract,
    Color? diseaseUnknown,
    Color? bg,
    Color? bgSurface,
    Color? card,
    Color? cardAlt,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    List<Color>? primaryGradient,
    List<Color>? bgGradient,
    List<Color>? cardGradient,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      diseaseNormal: diseaseNormal ?? this.diseaseNormal,
      diseaseConjunctivitis: diseaseConjunctivitis ?? this.diseaseConjunctivitis,
      diseaseCataract: diseaseCataract ?? this.diseaseCataract,
      diseaseUnknown: diseaseUnknown ?? this.diseaseUnknown,
      bg: bg ?? this.bg,
      bgSurface: bgSurface ?? this.bgSurface,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      bgGradient: bgGradient ?? this.bgGradient,
      cardGradient: cardGradient ?? this.cardGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      diseaseNormal: Color.lerp(diseaseNormal, other.diseaseNormal, t)!,
      diseaseConjunctivitis:
          Color.lerp(diseaseConjunctivitis, other.diseaseConjunctivitis, t)!,
      diseaseCataract: Color.lerp(diseaseCataract, other.diseaseCataract, t)!,
      diseaseUnknown: Color.lerp(diseaseUnknown, other.diseaseUnknown, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryGradient: primaryGradient, // gradients don't lerp meaningfully
      bgGradient: bgGradient,
      cardGradient: cardGradient,
    );
  }
}