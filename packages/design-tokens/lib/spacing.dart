import 'package:flutter/widgets.dart';

/// Named spacing tokens mirroring the Stitch design system.
///
/// Stitch uses semantic names (`stack-md`, `gutter-card`, `margin-page`,
/// `section-gap`) rather than a numeric scale. We mirror them here so
/// designers and engineers speak the same language.
class TastySpacing {
  TastySpacing._();

  /// Base unit — the building block of every other token. 8 dp.
  static const double unit = 8;

  /// 8 dp. Tight vertical rhythm (chip-to-chip, icon-to-label).
  static const double stackSm = 8;

  /// 16 dp. Default vertical spacing between paragraphs / form rows.
  static const double stackMd = 16;

  /// 32 dp. Vertical breathing room between major content blocks.
  static const double stackLg = 32;

  /// 20 dp. Internal padding inside a card or list tile.
  static const double gutterCard = 20;

  /// 24 dp. Horizontal page margin on phones.
  static const double marginPage = 24;

  /// 48 dp. Distance between two top-level page sections.
  static const double sectionGap = 48;

  // Ready-made EdgeInsets for the most common cases.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: marginPage);
  static const EdgeInsets cardPadding = EdgeInsets.all(gutterCard);
  static const EdgeInsets stackedItem = EdgeInsets.symmetric(vertical: stackSm);

  // Generic gap widgets — saves a SizedBox-with-magic-numbers everywhere.
  static const SizedBox gapXs = SizedBox(width: unit / 2, height: unit / 2);
  static const SizedBox gapSm = SizedBox(width: stackSm, height: stackSm);
  static const SizedBox gapMd = SizedBox(width: stackMd, height: stackMd);
  static const SizedBox gapLg = SizedBox(width: stackLg, height: stackLg);
}
