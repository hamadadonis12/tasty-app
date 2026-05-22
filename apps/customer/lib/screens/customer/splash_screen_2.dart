import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `tastylife_splash_screen_2` — value-prop pre-onboarding hero.
///
/// Full-bleed cinematic background, brand wordmark, headline + sub, two
/// CTAs (Get Started + Sign In).
class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key, this.onContinue, this.onSignIn});
  final VoidCallback? onContinue;
  /// "I already have an account" tap — used by the production OnboardingFlow
  /// to skip the full sign-up chain and drop returning users on Home directly.
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=1400&q=85',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0x00000000), Color(0xEE000000)],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.restaurant_menu, color: scheme.onPrimary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('TastyLife',
                          style: text.titleLarge?.copyWith(color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Text('The taste of Kinshasa,\ndelivered.',
                      style: text.displayMedium?.copyWith(color: Colors.white, height: 1.05)),
                  const SizedBox(height: TastySpacing.stackMd),
                  Text(
                    'Premium local kitchens, brutally honest ETAs, drivers '
                    'you know by name.',
                    style: text.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: TastySpacing.stackLg),
                  FilledButton(
                    onPressed: () => onContinue?.call(),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(height: TastySpacing.stackSm),
                  TextButton(
                    onPressed: () => (onSignIn ?? onContinue)?.call(),
                    child: Text('I already have an account',
                        style: text.labelLarge?.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
