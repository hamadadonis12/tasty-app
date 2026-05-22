import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Type ramp mirroring the Stitch design system.
///
/// - Display / titles → **Inter** (tight, modern, neutral).
/// - Body / captions  → **Plus Jakarta Sans** (humanist, friendly at small sizes).
///
/// Sizes: hero 32 / title-lg 24 / section-title 18 / body-main 15 / caption-md 12.
/// Legacy names (`headline`, `title`, `bodyLg`, `caption`, `labelSm`) are
/// retained so existing app code keeps compiling — they now point at the new
/// Stitch ramp.
class TastyTypography {
  TastyTypography._();

  static const String displayFontFamily = 'Inter';
  static const String bodyFontFamily = 'Plus Jakarta Sans';

  // Legacy field — kept so existing code that references it still compiles.
  static const String uiFontFamily = displayFontFamily;
  static const String logoFontFamily = displayFontFamily;

  // ---------- Display / titles (Inter) ----------
  static TextStyle get hero => GoogleFonts.inter(
        fontSize: 32,
        height: 1.2,
        letterSpacing: -0.02 * 32,
        fontWeight: FontWeight.w700,
        color: TastyColors.onSurface,
      );

  static TextStyle get titleLg => GoogleFonts.inter(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: TastyColors.onSurface,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: TastyColors.onSurface,
      );

  // ---------- Body / captions (Plus Jakarta Sans) ----------
  static TextStyle get bodyMain => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: TastyColors.onSurface,
      );

  static TextStyle get bodyEmphasis => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.6,
        fontWeight: FontWeight.w600,
        color: TastyColors.onSurface,
      );

  static TextStyle get captionMd => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 0.01 * 12,
        fontWeight: FontWeight.w500,
        color: TastyColors.onSurfaceVariant,
      );

  static TextStyle get labelStrong => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 0.04 * 12,
        fontWeight: FontWeight.w700,
        color: TastyColors.onSurface,
      );

  // ---------- Legacy aliases (kept so existing screens render correctly) ----------
  // These MUST remain `const TextStyle` so existing code that wraps
  // `Text('...', style: TastyTypography.X)` inside a `const` Widget keeps
  // compiling. They reference font family by name only — actual font glyphs
  // come from the system / GoogleFonts cache once the new ramp is touched
  // anywhere else. Sizes upgraded from the old broken ramp (caption was 11,
  // labelSm was 9.5 — both below mobile readability bars).
  static const TextStyle headline = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: TastyColors.onSurface,
  );
  static const TextStyle title = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: TastyColors.onSurface,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 15,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: TastyColors.onSurface,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: TastyColors.onSurfaceVariant,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w700,
    color: TastyColors.onSurfaceVariant,
  );

  /// Full Material 3 [TextTheme] anchored on the Stitch ramp.
  ///
  /// Color comes from the supplied [ColorScheme] so the same builder works
  /// for both light and dark themes.
  static TextTheme textThemeFor(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    final onSurfaceVariant = scheme.onSurfaceVariant;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 56,
        height: 1.12,
        letterSpacing: -1.12,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 44,
        height: 1.16,
        letterSpacing: -0.88,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        height: 1.18,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        height: 1.2,
        letterSpacing: -0.64,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        height: 1.22,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.4,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 0.12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        height: 1.3,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),
    );
  }
}
