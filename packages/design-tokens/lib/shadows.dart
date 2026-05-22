import 'package:flutter/material.dart';

/// Shadow tokens for the "Luxe-Functional" aesthetic.
///
/// Two named shadows from the Stitch reference:
///   ambient — soft diffuse drop, used on cards and sheets
///   glow    — warm primary-tinted halo, used on hero CTAs and badges
///
/// Material elevation scale (0–5) is also exposed for ColorScheme alignment.
class TastyShadows {
  TastyShadows._();

  /// `box-shadow: 0 8px 30px rgba(0,0,0,0.05)`
  static const List<BoxShadow> ambient = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 30,
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
    ),
  ];

  /// `box-shadow: 0 8px 24px rgba(255,159,28,0.2)`
  static const List<BoxShadow> glow = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x33FF9F1C), // rgba(255,159,28,0.2)
    ),
  ];

  /// Deeper shadow for floating sheets and modals.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 60,
      color: Color(0x14000000), // rgba(0,0,0,0.08)
    ),
  ];

  /// Subtle outline-replacement shadow for elevated chips.
  static const List<BoxShadow> chip = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x0A000000), // rgba(0,0,0,0.04)
    ),
  ];

  // ---------- M3 elevation tints (0–5) ----------
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 3;
  static const double elevation3 = 6;
  static const double elevation4 = 8;
  static const double elevation5 = 12;
}
