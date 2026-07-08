import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `tastylife_splash_screen_1` — the first boot screen.
///
/// Brand mark on warm-cream background, subtle gradient halo behind it,
/// soft "loading" pulse. Used for cold start; auto-advances after ~1.4s
/// when [onContinue] is provided (production flow). In the gallery the
/// callback is `null`, so it stays put as a preview.
///
/// [onSkip] (if provided) renders a "Skip onboarding" button in the
/// bottom-right so returning users / demos can jump straight to home.
class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key, this.onContinue, this.onSkip});
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  Timer? _advance;

  @override
  void initState() {
    super.initState();
    if (widget.onContinue != null) {
      _advance = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) widget.onContinue!.call();
      });
    }
  }

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 0.9,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.25),
                    scheme.surface,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TastyLifeLogo(size: 140),
                const SizedBox(height: TastySpacing.stackLg),
                Text('Kinshasa · Brazzaville',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: TastySpacing.sectionGap),
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
          if (widget.onSkip != null)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: TextButton(
                  onPressed: () {
                    _advance?.cancel();
                    widget.onSkip!.call();
                  },
                  child: Text(
                    'Skip →',
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
