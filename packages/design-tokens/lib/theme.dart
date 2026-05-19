import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'radii.dart';

class TastyTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
      primaryColor: TastyColors.brand,
      scaffoldBackgroundColor: TastyColors.paper,
      fontFamily: TastyTypography.uiFontFamily,
      colorScheme: const ColorScheme.light(
        primary: TastyColors.brand,
        secondary: TastyColors.info,
        surface: TastyColors.paper,
        error: TastyColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: TastyColors.ink,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TastyTypography.headline,
        titleLarge: TastyTypography.title,
        bodyLarge: TastyTypography.bodyLg,
        bodySmall: TastyTypography.caption,
        labelSmall: TastyTypography.labelSm,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TastyColors.brand,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: TastyRadii.buttonRadius,
          ),
        ),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: TastyRadii.cardRadius,
        ),
      ),
    );
  }
}
