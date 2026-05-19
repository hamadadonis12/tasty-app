import 'package:flutter/material.dart';
import 'package:design_tokens/colors.dart';

class TastyTypography {
  static const String uiFontFamily = 'Inter';
  static const String logoFontFamily = 'Nunito';

  static const TextStyle headline = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: TastyColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TastyColors.ink,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: TastyColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: TastyColors.ink,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: TastyColors.ink,
  );
}
