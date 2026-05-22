import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'radii.dart';
import 'spacing.dart';
import 'typography.dart';

/// Light + dark themes built from the Stitch tokens.
///
/// `TastyTheme.defaultTheme` is kept as a getter (legacy name used by the
/// customer prototype) and now aliases [lightTheme].
class TastyTheme {
  TastyTheme._();

  /// Material 3 light scheme assembled from Stitch tokens.
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: TastyColors.primary,
    onPrimary: TastyColors.onPrimary,
    primaryContainer: TastyColors.primaryContainer,
    onPrimaryContainer: TastyColors.onPrimaryContainer,
    secondary: TastyColors.secondary,
    onSecondary: TastyColors.onSecondary,
    secondaryContainer: TastyColors.secondaryContainer,
    onSecondaryContainer: TastyColors.onSecondaryContainer,
    tertiary: TastyColors.tertiary,
    onTertiary: TastyColors.onTertiary,
    tertiaryContainer: TastyColors.tertiaryContainer,
    onTertiaryContainer: TastyColors.onTertiaryContainer,
    error: TastyColors.error,
    onError: TastyColors.onError,
    errorContainer: TastyColors.errorContainer,
    onErrorContainer: TastyColors.onErrorContainer,
    surface: TastyColors.surface,
    onSurface: TastyColors.onSurface,
    surfaceContainerLowest: TastyColors.surfaceContainerLowest,
    surfaceContainerLow: TastyColors.surfaceContainerLow,
    surfaceContainer: TastyColors.surfaceContainer,
    surfaceContainerHigh: TastyColors.surfaceContainerHigh,
    surfaceContainerHighest: TastyColors.surfaceContainerHighest,
    surfaceDim: TastyColors.surfaceDim,
    surfaceBright: TastyColors.surfaceBright,
    onSurfaceVariant: TastyColors.onSurfaceVariant,
    outline: TastyColors.outline,
    outlineVariant: TastyColors.outlineVariant,
    inverseSurface: TastyColors.inverseSurface,
    onInverseSurface: TastyColors.inverseOnSurface,
    inversePrimary: TastyColors.inversePrimary,
    surfaceTint: TastyColors.surfaceTint,
    scrim: TastyColors.scrim,
    shadow: TastyColors.shadow,
  );

  /// Material 3 dark scheme assembled from Stitch tokens.
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: TastyColors.primaryDark,
    onPrimary: TastyColors.onPrimaryDark,
    primaryContainer: TastyColors.primaryContainerDark,
    onPrimaryContainer: TastyColors.onPrimaryContainerDark,
    secondary: TastyColors.secondaryDark,
    onSecondary: TastyColors.onSecondaryDark,
    secondaryContainer: TastyColors.secondaryContainerDark,
    onSecondaryContainer: TastyColors.onSecondaryContainerDark,
    tertiary: TastyColors.tertiaryDark,
    onTertiary: TastyColors.onTertiaryDark,
    tertiaryContainer: TastyColors.tertiaryContainerDark,
    onTertiaryContainer: TastyColors.onTertiaryContainerDark,
    error: TastyColors.errorDark,
    onError: TastyColors.onErrorDark,
    errorContainer: TastyColors.errorContainerDark,
    onErrorContainer: TastyColors.onErrorContainerDark,
    surface: TastyColors.surfaceDark,
    onSurface: TastyColors.onSurfaceDark,
    surfaceContainerLowest: TastyColors.surfaceContainerLowestDark,
    surfaceContainerLow: TastyColors.surfaceContainerLowDark,
    surfaceContainer: TastyColors.surfaceContainerDark,
    surfaceContainerHigh: TastyColors.surfaceContainerHighDark,
    surfaceContainerHighest: TastyColors.surfaceContainerHighestDark,
    surfaceDim: TastyColors.surfaceDimDark,
    surfaceBright: TastyColors.surfaceBrightDark,
    onSurfaceVariant: TastyColors.onSurfaceVariantDark,
    outline: TastyColors.outlineDark,
    outlineVariant: TastyColors.outlineVariantDark,
    inverseSurface: TastyColors.inverseSurfaceDark,
    onInverseSurface: TastyColors.inverseOnSurfaceDark,
    inversePrimary: TastyColors.inversePrimaryDark,
    surfaceTint: TastyColors.surfaceTintDark,
    scrim: TastyColors.scrim,
    shadow: TastyColors.shadow,
  );

  static ThemeData get lightTheme => _buildTheme(lightScheme);
  static ThemeData get darkTheme => _buildTheme(darkScheme);

  /// Legacy alias used by the existing customer / driver prototypes.
  static ThemeData get defaultTheme => lightTheme;

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = TastyTypography.textThemeFor(scheme);
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      fontFamily: TastyTypography.uiFontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ---------- App bar ----------
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ---------- Cards ----------
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: TastyRadii.xlRadius),
      ),

      // ---------- Buttons ----------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          disabledBackgroundColor: scheme.surfaceContainerHigh,
          disabledForegroundColor: scheme.onSurfaceVariant,
          elevation: 0,
          shadowColor: TastyColors.primaryContainer.withValues(alpha: 0.2),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: TastyRadii.fullRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: TastyRadii.fullRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: TastyRadii.fullRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: TastyRadii.fullRadius),
        ),
      ),

      // ---------- Inputs ----------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: TastyRadii.mdRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TastyRadii.mdRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TastyRadii.mdRadius,
          borderSide: BorderSide(color: scheme.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TastyRadii.mdRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      // ---------- Chips ----------
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: TastyRadii.fullRadius),
      ),

      // ---------- Sheets / dialogs ----------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surfaceContainerLowest,
        modalElevation: 0,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(TastyRadii.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: TastyRadii.xlRadius),
      ),

      // ---------- Navigation ----------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            size: 24,
          );
        }),
        elevation: 0,
        height: 72,
      ),

      // ---------- Dividers ----------
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: TastySpacing.stackMd,
      ),

      // ---------- Snackbars ----------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: TastyRadii.mdRadius),
      ),
    );
  }
}
