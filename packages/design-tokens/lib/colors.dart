import 'package:flutter/material.dart';

/// Material 3 color tokens mirrored from the TastyLife Stitch design system.
///
/// Naming follows M3 (`primary`, `primaryContainer`, `onSurface`, etc.) so
/// these values map 1:1 onto Flutter's [ColorScheme]. Legacy aliases
/// (`brand`, `ink`, `paper`, `success`, `warning`, `danger`, `info`) are kept
/// so existing app code keeps compiling.
class TastyColors {
  TastyColors._();

  // ---------- Light scheme ----------
  static const Color primary = Color(0xFF895100);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF9F1C);
  static const Color onPrimaryContainer = Color(0xFF683C00);
  static const Color primaryFixed = Color(0xFFFFDCBC);
  static const Color primaryFixedDim = Color(0xFFFFB86B);
  static const Color onPrimaryFixed = Color(0xFF2C1700);
  static const Color onPrimaryFixedVariant = Color(0xFF683D00);

  static const Color secondary = Color(0xFF5D5F5D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE2E3E0);
  static const Color onSecondaryContainer = Color(0xFF636563);
  static const Color secondaryFixed = Color(0xFFE2E3E0);
  static const Color secondaryFixedDim = Color(0xFFC6C7C4);
  static const Color onSecondaryFixed = Color(0xFF1A1C1B);
  static const Color onSecondaryFixedVariant = Color(0xFF454745);

  static const Color tertiary = Color(0xFF5D5F5F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB4B5B5);
  static const Color onTertiaryContainer = Color(0xFF454747);
  static const Color tertiaryFixed = Color(0xFFE2E2E2);
  static const Color tertiaryFixedDim = Color(0xFFC6C6C7);
  static const Color onTertiaryFixed = Color(0xFF1A1C1C);
  static const Color onTertiaryFixedVariant = Color(0xFF454747);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFFCF9F8);
  static const Color onBackground = Color(0xFF1C1B1B);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color surfaceBright = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceVariant = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFF544434);
  static const Color surfaceTint = Color(0xFF895100);
  static const Color inverseSurface = Color(0xFF313030);
  static const Color inverseOnSurface = Color(0xFFF3F0EF);
  static const Color inversePrimary = Color(0xFFFFB86B);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDEC);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);

  static const Color outline = Color(0xFF877462);
  static const Color outlineVariant = Color(0xFFDAC2AE);
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);

  // ---------- Dark scheme (LogisAFRICA / immersive_home_dark) ----------
  static const Color primaryDark = Color(0xFFFFB86B);
  static const Color onPrimaryDark = Color(0xFF492900);
  static const Color primaryContainerDark = Color(0xFF683D00);
  static const Color onPrimaryContainerDark = Color(0xFFFFDCBC);

  static const Color secondaryDark = Color(0xFFC6C7C4);
  static const Color onSecondaryDark = Color(0xFF2F312F);
  static const Color secondaryContainerDark = Color(0xFF454745);
  static const Color onSecondaryContainerDark = Color(0xFFE2E3E0);

  static const Color tertiaryDark = Color(0xFFC6C6C7);
  static const Color onTertiaryDark = Color(0xFF2F3131);
  static const Color tertiaryContainerDark = Color(0xFF454747);
  static const Color onTertiaryContainerDark = Color(0xFFE2E2E2);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color backgroundDark = Color(0xFF141313);
  static const Color onBackgroundDark = Color(0xFFE5E2E1);
  static const Color surfaceDark = Color(0xFF141313);
  static const Color onSurfaceDark = Color(0xFFE5E2E1);
  static const Color surfaceBrightDark = Color(0xFF3A3939);
  static const Color surfaceDimDark = Color(0xFF141313);
  static const Color surfaceVariantDark = Color(0xFF544434);
  static const Color onSurfaceVariantDark = Color(0xFFDAC2AE);
  static const Color surfaceTintDark = Color(0xFFFFB86B);
  static const Color inverseSurfaceDark = Color(0xFFE5E2E1);
  static const Color inverseOnSurfaceDark = Color(0xFF313030);
  static const Color inversePrimaryDark = Color(0xFF895100);

  static const Color surfaceContainerLowestDark = Color(0xFF0E0E0E);
  static const Color surfaceContainerLowDark = Color(0xFF1C1B1B);
  static const Color surfaceContainerDark = Color(0xFF201F1F);
  static const Color surfaceContainerHighDark = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighestDark = Color(0xFF353434);

  static const Color outlineDark = Color(0xFFA38C7A);
  static const Color outlineVariantDark = Color(0xFF544434);

  // ---------- Semantic / utility ----------
  static const Color success = Color(0xFF1F8F4D);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFBDF0CE);
  static const Color onSuccessContainer = Color(0xFF003919);

  static const Color warning = Color(0xFFB36B00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B5);
  static const Color onWarningContainer = Color(0xFF3A2300);

  static const Color info = Color(0xFF1E63D6);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFD7E3FF);
  static const Color onInfoContainer = Color(0xFF001A41);

  // ---------- Tasty Life · 2026 brand refresh (Claude Design export) ----------
  // Brighter orange + black ink for premium black-and-orange contrast. Used by
  // screens ported from the customer-app-v2 design canvas (chat, schedule,
  // coupons, …). Existing screens keep using the M3 primary container which
  // is now mapped to this brighter orange for consistency.
  static const Color brandOrange = Color(0xFFFF9A31);
  static const Color brandOrangeDeep = Color(0xFFF27A0E);
  static const Color brandOrangeSoft = Color(0xFFFFE9CF);
  static const Color brandOrangeTint = Color(0xFFFFF5EA);

  /// Off-black used for chrome, dense data, dark hero cards, and OTP filled
  /// states. Distinct from [onSurface] so it can be referenced directly.
  static const Color brandInk = Color(0xFF0A0A0A);
  static const Color brandInkSoft = Color(0xFF111111);

  /// Muted warm grays for secondary text on the new design.
  static const Color brandMute = Color(0xFF8A8680);
  static const Color brandMuteSoft = Color(0xFFBEBAB2);
  static const Color brandLine = Color(0xFFECEAE3);
  static const Color brandLineSoft = Color(0xFFF2F0EA);

  // ---------- Legacy aliases (do not remove — existing app code references these) ----------
  static const Color brand = primaryContainer; // vivid orange accent
  static const Color ink = onSurface;
  static const Color paper = background;
  static const Color danger = error;
}
