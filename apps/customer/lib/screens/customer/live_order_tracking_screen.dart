import 'dart:async';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'chat_with_driver_screen.dart';
import 'rate_experience_screen.dart';

/// `live_order_tracking` from the Stitch reference.
///
/// Ambient gradient "map" (placeholder until Mapbox lands) → driver pin →
/// ETA-as-hero card → driver card with call/message → order summary.
///
/// Polish: the ETA hero animates one minute back every 4s so the screen
/// always feels alive in the gallery preview.
class LiveOrderTrackingScreen extends StatefulWidget {
  const LiveOrderTrackingScreen({super.key});
  @override
  State<LiveOrderTrackingScreen> createState() => _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState extends State<LiveOrderTrackingScreen> {
  Timer? _ticker;
  late int _minute;

  ActiveOrder? get _order => CartController.instance.activeOrder;

  @override
  void initState() {
    super.initState();
    _minute = _order?.etaMinute ?? 42;
    _ticker = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _minute = (_minute - 1).clamp(20, 59));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Top bar ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('ORDER #${_order?.orderId ?? "TL-DEMO"}',
                            style: text.labelSmall?.copyWith(letterSpacing: 1.4)),
                        Text('Arriving Soon',
                            style: text.titleMedium?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
                ],
              ),
            ),
            // ---------- Map area ----------
            Expanded(
              child: Stack(
                children: [
                  // Ambient warm gradient as map placeholder.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.1,
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.3),
                            scheme.surfaceContainerLow,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Approaching badge.
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: TastyRadii.fullRadius,
                          boxShadow: TastyShadows.glow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pedal_bike, color: scheme.onPrimaryContainer, size: 18),
                            const SizedBox(width: 8),
                            Text('Driver is approaching',
                                style: text.labelLarge?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Restaurant icon.
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: TastyShadows.ambient,
                      ),
                      child: Icon(Icons.restaurant, color: scheme.onSurfaceVariant, size: 24),
                    ),
                  ),
                  // Driver bike pin + minute label.
                  Align(
                    alignment: const Alignment(0, 0.45),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: TastyShadows.glow,
                          ),
                          child: Icon(Icons.pedal_bike, color: scheme.onPrimary, size: 26),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            borderRadius: TastyRadii.fullRadius,
                            boxShadow: TastyShadows.ambient,
                          ),
                          child: Text('4 min', style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ---------- Status / driver / order ----------
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                boxShadow: TastyShadows.sheet,
              ),
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ETA-as-hero.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Arrival',
                                style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                            AnimatedSwitcher(
                              duration: TastyMotion.durationMd,
                              transitionBuilder: (child, anim) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.35),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: Text(
                                '19:${_minute.toString().padLeft(2, '0')}',
                                key: ValueKey(_minute),
                                style: text.displayLarge?.copyWith(
                                  fontSize: 44,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TastyColors.successContainer,
                          borderRadius: TastyRadii.fullRadius,
                        ),
                        child: Text('On time',
                            style: text.labelMedium?.copyWith(
                              color: TastyColors.onSuccessContainer,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar.
                  ClipRRect(
                    borderRadius: TastyRadii.fullRadius,
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
                    ),
                  ),
                  const SizedBox(height: TastySpacing.stackLg),
                  // Driver card.
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
                        ),
                      ),
                      const SizedBox(width: TastySpacing.stackMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_order?.driverName ?? 'Jean Kabila',
                                style: text.titleSmall),
                            Row(
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: scheme.primary),
                                const SizedBox(width: 4),
                                Text('4.9 · Honda PCX', style: text.labelMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _CircleButton(icon: Icons.call, onTap: HapticFeedback.lightImpact),
                      const SizedBox(width: 8),
                      _CircleButton(
                        icon: Icons.chat_bubble,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChatWithDriverScreen()),
                          );
                        },
                        filled: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  const Divider(height: 1),
                  const SizedBox(height: TastySpacing.stackMd),
                  // Order summary row — wired to ActiveOrder so it actually
                  // matches what the customer paid for.
                  Builder(builder: (_) {
                    final order = _order;
                    final restaurant = order?.restaurantName ?? 'TastyLife';
                    final itemCount = order?.itemCount ?? 0;
                    final total = order?.total ?? 0;
                    return Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: scheme.primary),
                        const SizedBox(width: TastySpacing.stackMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(restaurant, style: text.titleSmall),
                              Text(
                                '$itemCount item${itemCount == 1 ? '' : 's'} · Paid',
                                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text('\$${total.toStringAsFixed(2)}', style: text.titleSmall),
                      ],
                    );
                  }),
                  const SizedBox(height: TastySpacing.stackMd),
                  // Customer-side CTA — when the driver hands off the
                  // package, the customer marks the order as received and
                  // rates the experience. No camera, no signature, no
                  // courier handoff buttons.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RateExperienceScreen()),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("I've received my order"),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final fg = filled ? scheme.onPrimaryContainer : scheme.onSurface;
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}
