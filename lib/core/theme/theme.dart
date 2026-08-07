import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
export 'theme_extension.dart';
export 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static AppColors activeColors = AppColors.dark;

  static void syncWithBrightness(Brightness brightness) {
    activeColors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }

  // ── Border Radius (mode-independent) ────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ── Spacing (mode-independent) ──────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ── Text Styles (mode-independent structure; color applied at
  //    call sites via context.colors, or via TextTheme below) ──────
  static const TextStyle _displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );
  static const TextStyle _displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );
  static const TextStyle _headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const TextStyle _headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle _bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle _bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle _labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Public text styles (exposed for use across the app)
  static const TextStyle displayLarge = _displayLarge;
  static const TextStyle displayMedium = _displayMedium;
  static const TextStyle headlineLarge = _headlineLarge;
  static const TextStyle headlineMedium = _headlineMedium;
  static const TextStyle bodyLarge = _bodyLarge;
  static const TextStyle bodyMedium = _bodyMedium;
  static const TextStyle bodySmall = _bodySmall;
  static const TextStyle labelLarge = _labelLarge;

  static List<BoxShadow> cardShadow(Brightness brightness) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.3 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glowShadow(Color primary) => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  // Convenience getters that expose semantic colors/gradients for code that
  // references `AppTheme.<name>` directly. These return dark-mode values as
  // sensible defaults but callers should prefer `context.colors` for mode-aware
  // values when possible.
  static Color get primary => activeColors.primary;
  static Color get secondary => activeColors.secondary;
  static Color get accent => activeColors.accent;
  static Color get success => activeColors.success;
  static Color get warning => activeColors.warning;
  static Color get error => activeColors.error;

  static Color get bgDark => activeColors.bg;
  static Color get bgCard => activeColors.card;
  static Color get bgCardAlt => activeColors.cardAlt;
  static Color get borderColor => activeColors.border;

  static Color get textPrimary => activeColors.textPrimary;
  static Color get textSecondary => activeColors.textSecondary;
  static Color get textMuted => activeColors.textMuted;

  static Color get colorNormal => activeColors.diseaseNormal;
  static Color get colorConjunctivitis => activeColors.diseaseConjunctivitis;
  static Color get colorCataract => activeColors.diseaseCataract;
  static Color get colorUnknown => activeColors.diseaseUnknown;

  static LinearGradient get primaryGradient => LinearGradient(colors: activeColors.primaryGradient);
  static LinearGradient get bgGradient => LinearGradient(colors: activeColors.bgGradient);

  // ── Build ThemeData for a given mode + color set ────────────────
  static ThemeData _buildTheme(Brightness brightness, AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: colors.primary,
              secondary: colors.secondary,
              surface: colors.bgSurface,
              error: colors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: colors.textPrimary,
            )
          : ColorScheme.light(
              primary: colors.primary,
              secondary: colors.secondary,
              surface: colors.bgSurface,
              error: colors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: colors.textPrimary,
            ),
      extensions: [colors],
      textTheme: TextTheme(
        displayLarge: _displayLarge.copyWith(color: colors.textPrimary),
        displayMedium: _displayMedium.copyWith(color: colors.textPrimary),
        headlineLarge: _headlineLarge.copyWith(color: colors.textPrimary),
        headlineMedium: _headlineMedium.copyWith(color: colors.textPrimary),
        bodyLarge: _bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: _bodyMedium.copyWith(color: colors.textSecondary),
        bodySmall: _bodySmall.copyWith(color: colors.textMuted),
        labelLarge: _labelLarge.copyWith(color: colors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: BorderSide(color: colors.primary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bgSurface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardAlt,
        contentTextStyle: TextStyle(color: colors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, AppColors.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light, AppColors.light);
}