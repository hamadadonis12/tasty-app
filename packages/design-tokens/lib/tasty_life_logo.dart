import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// The TastyLife brand mark.
///
/// Chunky black **TASTY** in Bagel Fat One sitting on top of an orange
/// semicircle that contains a smaller white **LIFE** wordmark. Mirrors the
/// SVG in the Claude Design `tokens.jsx` bundle.
///
/// ```dart
/// TastyLifeLogo(size: 96)
/// TastyLifeLogo.compact()  // square 48 logo for app bars
/// ```
class TastyLifeLogo extends StatelessWidget {
  const TastyLifeLogo({
    super.key,
    this.size = 96,
    this.inkColor = TastyColors.brandInk,
    this.accentColor = TastyColors.brandOrange,
  });

  /// Default smaller variant for app bars and dense headers (48 dp).
  const TastyLifeLogo.compact({super.key})
      : size = 48,
        inkColor = TastyColors.brandInk,
        accentColor = TastyColors.brandOrange;

  final double size;
  final Color inkColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    // Wordmark scales with the bounding size; we draw a square logo.
    final tastyStyle = GoogleFonts.bagelFatOne(
      fontSize: size * 0.30,
      color: inkColor,
      letterSpacing: -0.5,
      height: 1.0,
    );
    final lifeStyle = GoogleFonts.inter(
      fontSize: size * 0.14,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: 2.4,
      height: 1.0,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orange semicircle, bottom half of a circle inset from the edges.
          Positioned(
            left: 0,
            right: 0,
            top: size * 0.5,
            bottom: size * 0.12,
            child: CustomPaint(
              painter: _SemicirclePainter(accentColor),
            ),
          ),
          // "TASTY" wordmark sitting above the half-circle line.
          Positioned(
            top: size * 0.20,
            child: Text('TASTY', style: tastyStyle),
          ),
          // "LIFE" wordmark inside the orange semicircle.
          Positioned(
            top: size * 0.68,
            child: Text('LIFE', style: lifeStyle),
          ),
        ],
      ),
    );
  }
}

class _SemicirclePainter extends CustomPainter {
  _SemicirclePainter(this.fill);
  final Color fill;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = fill;
    final rect = Rect.fromLTWH(0, -size.height, size.width, size.height * 2);
    // Bottom-half arc: draw a full circle then clip to a rectangle whose top
    // sits at the diameter line. Easier: draw an arc from 0 to π across the
    // bounding circle of the rect.
    final path = Path()
      ..moveTo(0, 0)
      ..arcTo(rect, 0, 3.14159, false)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
