import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'live_order_tracking_screen.dart';

/// `order_success_celebration` from the Stitch reference.
///
/// Full-bleed gradient background, a confetti motif, big checkmark, order
/// summary card, and two CTAs (Track Order, Back to Home).
class OrderSuccessCelebrationScreen extends StatefulWidget {
  const OrderSuccessCelebrationScreen({super.key});
  @override
  State<OrderSuccessCelebrationScreen> createState() => _OrderSuccessCelebrationScreenState();
}

class _OrderSuccessCelebrationScreenState
    extends State<OrderSuccessCelebrationScreen> with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: TastyMotion.durationLg,
    )..forward();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    // Success haptic on entry.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => HapticFeedback.heavyImpact(),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.25),
              scheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(progress: _confettiController.value),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(TastySpacing.marginPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Center(
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _checkController,
                          curve: TastyMotion.emphasizedDecelerate,
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: TastyShadows.glow,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: scheme.onPrimaryContainer,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackLg),
                    Text('Order Confirmed!',
                        textAlign: TextAlign.center,
                        style: text.displaySmall),
                    const SizedBox(height: 8),
                    Builder(builder: (_) {
                      final order = CartController.instance.activeOrder;
                      final restaurant = order?.restaurantName ?? 'TastyLife';
                      final eta = order?.etaMinute ?? 22;
                      return Text(
                        'Your meal is on its way from $restaurant.\n'
                        'Estimated arrival in $eta minutes.',
                        textAlign: TextAlign.center,
                        style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      );
                    }),
                    const SizedBox(height: TastySpacing.sectionGap),
                    Builder(builder: (_) {
                      final order = CartController.instance.activeOrder;
                      // Fallback values for gallery preview where the user
                      // didn't place a real order.
                      final orderId = order?.orderId ?? 'TL-DEMO';
                      final subtotal = order?.subtotal ?? 15.00;
                      final delivery = order?.deliveryFee ?? 2.00;
                      final service = order?.serviceFee ?? 0.50;
                      final total = order?.total ?? 17.50;
                      final payment = order?.paymentLabel ?? 'Orange Money';
                      return Container(
                        padding: const EdgeInsets.all(TastySpacing.gutterCard),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest,
                          borderRadius: TastyRadii.xlRadius,
                          boxShadow: TastyShadows.ambient,
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(label: 'Order #', value: orderId),
                            const Divider(height: 24),
                            _SummaryRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
                            _SummaryRow(label: 'Delivery', value: '\$${delivery.toStringAsFixed(2)}'),
                            _SummaryRow(label: 'Service fee', value: '\$${service.toStringAsFixed(2)}'),
                            const Divider(height: 24),
                            _SummaryRow(
                              label: 'Total · $payment',
                              value: '\$${total.toStringAsFixed(2)}',
                              emphasis: true,
                            ),
                          ],
                        ),
                      );
                    }),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LiveOrderTrackingScreen()),
                        );
                      },
                      child: const Text('Track Order'),
                    ),
                    const SizedBox(height: TastySpacing.stackSm),
                    OutlinedButton(
                      onPressed: () {
                        // Pop back to the home shell at the root of the navigator stack.
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Back to Home'),
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasis = false});
  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final style = emphasis
        ? text.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)
        : text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;
  static const _colors = <Color>[
    TastyColors.primary,
    TastyColors.primaryContainer,
    TastyColors.success,
    TastyColors.info,
    TastyColors.warning,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint();
    for (int i = 0; i < 32; i++) {
      final x = rng.nextDouble() * size.width;
      final yStart = -20.0 - rng.nextDouble() * 80;
      final fall = (progress + i * 0.07) % 1.0;
      final y = yStart + fall * (size.height + 100);
      final color = _colors[i % _colors.length].withValues(alpha: 0.85);
      paint.color = color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(fall * 6.28 * (i.isEven ? 1 : -1));
      canvas.drawRect(const Rect.fromLTWH(-3, -6, 6, 12), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
