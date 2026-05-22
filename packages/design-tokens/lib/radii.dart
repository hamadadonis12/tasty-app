import 'package:flutter/material.dart';

/// Corner radius tokens mirroring the Stitch design system.
///
/// Stitch uses: default 4, lg 8, xl 12, 2xl 24, full 9999. We expose them as
/// raw doubles and as [BorderRadius] for convenience, plus legacy aliases
/// that earlier app code already references.
class TastyRadii {
  TastyRadii._();

  // M3 / Stitch raw values
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 9999;

  // M3 / Stitch BorderRadius values
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));

  // ---------- Legacy aliases (kept so existing code compiles) ----------
  static const double badge = xs;
  static const double stepper = sm;
  static const double button = lg; // bumped from 14 → 16 to match Stitch button radius
  static const double card = xl; // bumped from 18 → 24 to match Stitch 2xl
  static const double pill = full;

  static const BorderRadius badgeRadius = xsRadius;
  static const BorderRadius stepperRadius = smRadius;
  static const BorderRadius buttonRadius = lgRadius;
  static const BorderRadius cardRadius = xlRadius;
  static const BorderRadius pillRadius = fullRadius;
}
