import 'package:flutter/animation.dart';

/// Motion tokens — durations and easing curves used across the apps.
///
/// Aligned with Material 3 motion guidelines: short transitions for
/// state changes, medium for component-level motion, long for hero
/// transitions across screens.
class TastyMotion {
  TastyMotion._();

  // ---------- Duration tokens ----------
  static const Duration durationXs = Duration(milliseconds: 100);
  static const Duration durationSm = Duration(milliseconds: 200);
  static const Duration durationMd = Duration(milliseconds: 300);
  static const Duration durationLg = Duration(milliseconds: 500);
  static const Duration durationXl = Duration(milliseconds: 700);

  // ---------- Easing tokens ----------

  /// Default easing for symmetric state changes (hover, ripple).
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// Decelerated — for elements arriving on screen.
  static const Curve decelerate = Cubic(0, 0, 0, 1);

  /// Accelerated — for elements leaving the screen.
  static const Curve accelerate = Cubic(0.3, 0, 1, 1);

  /// Emphasized — for hero / brand-defining transitions.
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// Emphasized decelerate — entrance of a hero element.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);

  /// Emphasized accelerate — exit of a hero element.
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
}
