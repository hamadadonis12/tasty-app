import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `login_verification` — phone entry with +243 default + Send Code,
/// followed by 6-cell OTP input with Resend, WhatsApp fallback card.
///
/// The OTP grid is a visual decoration over a real hidden [TextField] that
/// captures the keyboard. Tapping any cell focuses the field; entered
/// digits land in the visible cells and auto-advance the active index.
class LoginVerificationScreen extends StatefulWidget {
  const LoginVerificationScreen({super.key, this.onContinue});
  final VoidCallback? onContinue;
  @override
  State<LoginVerificationScreen> createState() => _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _otpCtrl.addListener(_onOtpChanged);
  }

  void _onOtpChanged() {
    setState(() {});
    if (_otpCtrl.text.length == 6) {
      HapticFeedback.mediumImpact();
      // Tiny delay so the last digit registers visually before advancing.
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        widget.onContinue?.call();
      });
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.removeListener(_onOtpChanged);
    _otpCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final entered = _otpCtrl.text;
    final activeIndex = entered.length.clamp(0, 5);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Back', style: text.displaySmall),
            const SizedBox(height: 6),
            Text(
              'Enter your phone number to seamlessly re-enter the Kinshasa Eats ecosystem.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            // Phone card
            Container(
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: TastyRadii.xxlRadius,
                boxShadow: TastyShadows.ambient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHONE NUMBER',
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.4,
                      )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: TastyRadii.lgRadius,
                        ),
                        child: Row(
                          children: [
                            Text('+243', style: text.titleSmall),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more, color: scheme.onSurfaceVariant, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '000 000 000',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _otpFocus.requestFocus();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Send Code'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            Row(
              children: [
                Expanded(
                  child: Text('AUTHORIZATION CODE',
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.4,
                      )),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _otpCtrl.clear();
                    _otpFocus.requestFocus();
                  },
                  child: const Text('Resend'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // OTP cells with real keyboard capture.
            Stack(
              children: [
                // Visual cells (decorative).
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final filled = i < entered.length;
                    final isActive = i == activeIndex;
                    return Container(
                      width: 48, height: 56,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: TastyRadii.lgRadius,
                        border: Border.all(
                          color: isActive ? scheme.primary : scheme.outlineVariant,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filled ? entered[i] : '',
                        style: text.headlineSmall?.copyWith(color: scheme.primary),
                      ),
                    );
                  }),
                ),
                // Invisible TextField that owns the keyboard and the text.
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.01,
                    child: TextField(
                      controller: _otpCtrl,
                      focusNode: _otpFocus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enableSuggestions: false,
                      autocorrect: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            // WhatsApp fallback
            InkWell(
              borderRadius: TastyRadii.xlRadius,
              onTap: HapticFeedback.lightImpact,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: TastyRadii.xlRadius,
                  boxShadow: TastyShadows.ambient,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chat, color: scheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WhatsApp Fallback', style: text.titleSmall),
                          Text('Receive code via chat', style: text.labelMedium),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
