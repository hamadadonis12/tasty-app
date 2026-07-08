import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'screens/customer/delivery_address_setup_screen.dart';
import 'screens/customer/home_shell.dart';
import 'screens/customer/login_verification_screen.dart';
import 'screens/customer/permissions_onboarding_screen.dart';
import 'screens/customer/select_language_screen.dart';
import 'screens/customer/splash_screen_1.dart';
import 'screens/customer/splash_screen_2.dart';

/// Production entry point for the TastyLife customer app.
///
/// Boots through a five-step onboarding flow (splash → language →
/// permissions → login → address) then lands on the immersive home.
/// The standalone gallery lives at `lib/gallery_app.dart`.
void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the customer changes the theme preference in
    // Appearance settings, so light/dark/system switches take effect live.
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => MaterialApp(
        title: 'TastyLife',
        debugShowCheckedModeBanner: false,
        theme: TastyTheme.lightTheme,
        darkTheme: TastyTheme.darkTheme,
        themeMode: AppState.instance.themeMode,
        home: const OnboardingFlow(),
      ),
    );
  }
}

/// Five-step onboarding pager. Each step provides a `next` callback that
/// the corresponding screen calls from its primary CTA. After step 5 we
/// swap the home tree for the [ImmersiveHomeScreen].
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;

  void _next() => setState(() => _step += 1);
  /// Jump straight to the HomeShell — used by Splash 2's
  /// "I already have an account" so returning users skip the full chain.
  void _signIn() => setState(() => _step = 6);

  @override
  Widget build(BuildContext context) {
    final child = switch (_step) {
      0 => SplashScreen1(onContinue: _next, onSkip: _signIn),
      1 => SplashScreen2(onContinue: _next, onSignIn: _signIn),
      2 => SelectLanguageScreen(onContinue: _next),
      3 => PermissionsOnboardingScreen(onContinue: _next, onSkip: _next),
      4 => LoginVerificationScreen(onContinue: _next),
      5 => DeliveryAddressSetupScreen(onConfirm: _next),
      _ => const HomeShell(),
    };
    // Cross-fade between flow steps for a calmer transition than the
    // default route push.
    return AnimatedSwitcher(
      duration: TastyMotion.durationMd,
      switchInCurve: TastyMotion.emphasizedDecelerate,
      switchOutCurve: TastyMotion.emphasizedAccelerate,
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
      child: KeyedSubtree(key: ValueKey(_step), child: child),
    );
  }
}
