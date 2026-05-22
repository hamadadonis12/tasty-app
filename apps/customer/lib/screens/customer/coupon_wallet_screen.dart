import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `AppCoupons` from the v2 design — Offers & coupons wallet.
///
/// Apply-code row → tab chips → big hand-picked dark hero coupon (with the
/// signature ticket notches) → list of smaller offers. DRC-localized to FC
/// currency and Kinshasa restaurant names.
class CouponWalletScreen extends StatelessWidget {
  const CouponWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Offers & coupons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Code apply row
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              borderRadius: TastyRadii.lgRadius,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: TastyColors.brandOrangeTint,
                    borderRadius: TastyRadii.smRadius,
                  ),
                  child: Text('CODE',
                      style: text.labelSmall?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        color: TastyColors.brandOrangeDeep,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Have a code? Paste it here…',
                      style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                FilledButton(
                  onPressed: HapticFeedback.lightImpact,
                  style: FilledButton.styleFrom(
                    backgroundColor: TastyColors.brandInk,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                Padding(padding: EdgeInsets.only(right: 6), child: _Chip(label: 'For you', active: true)),
                Padding(padding: EdgeInsets.only(right: 6), child: _Chip(label: 'All', active: false)),
                Padding(padding: EdgeInsets.only(right: 6), child: _Chip(label: 'New customer', active: false)),
                _Chip(label: 'Expiring', active: false),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Hand-picked hero coupon (dark with ticket notches)
          const _HeroCoupon(),
          const SizedBox(height: 12),
          // Smaller offers — DRC-localized restaurants
          ...const [
            _OfferData(emoji: '🎉', title: '5 000 FC off first order',
                sub: 'Min 25 000 FC · new customers',
                code: 'BIENVENU30', expires: '5 days left',
                bg: TastyColors.brandOrange),
            _OfferData(emoji: '🚀', title: 'Free delivery · 7 days',
                sub: 'Maison Kinshasa or Mama Lina',
                code: 'LIVRAISON', expires: 'Until 31 May',
                bg: TastyColors.brandInk),
            _OfferData(emoji: '☕', title: 'Buy 1 get 1 Bissap',
                sub: 'Mama Lina only',
                code: 'BISSAP2', expires: '2 days left',
                bg: Color(0xFFD93B3B)),
            _OfferData(emoji: '🌃', title: '15% late-night specials',
                sub: 'Orders after 22:00',
                code: 'TARDIF15', expires: 'Weekends',
                bg: Color(0xFF6B4C93)),
          ]
              .map((o) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _OfferRow(data: o),
                  )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? TastyColors.brandInk : scheme.surfaceContainerLow,
        borderRadius: TastyRadii.fullRadius,
      ),
      child: Text(label,
          style: text.labelMedium?.copyWith(
            color: active ? Colors.white : scheme.onSurface,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _HeroCoupon extends StatelessWidget {
  const _HeroCoupon();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TastyColors.brandInk,
            borderRadius: TastyRadii.lgRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: TastyColors.brandOrange, borderRadius: TastyRadii.fullRadius,
                ),
                child: Text('🔥 Hand-picked for you',
                    style: text.labelSmall?.copyWith(
                      color: TastyColors.brandInk,
                      fontWeight: FontWeight.w800,
                    )),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: '30% off ',
                  style: text.displaySmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: 'weekend',
                      style: text.displaySmall?.copyWith(
                        color: TastyColors.brandOrange, fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text('Up to 8 000 FC · on any order above 20 000 FC',
                  style: text.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.65))),
              const SizedBox(height: 14),
              const DashedDivider(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRES · SUN 31 MAY',
                            style: text.labelSmall?.copyWith(
                              fontFamily: 'JetBrains Mono',
                              color: Colors.white.withValues(alpha: 0.55),
                              letterSpacing: 1.0,
                            )),
                        const SizedBox(height: 3),
                        Text('WKND30',
                            style: text.titleMedium?.copyWith(
                              fontFamily: 'JetBrains Mono',
                              color: TastyColors.brandOrange,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            )),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: HapticFeedback.mediumImpact,
                    style: FilledButton.styleFrom(
                      backgroundColor: TastyColors.brandOrange,
                      foregroundColor: TastyColors.brandInk,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Use now →'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Ticket notches (left + right circles cut into the card)
        Positioned(
          left: -8, top: 0, bottom: 0,
          child: Center(child: _Notch(color: scheme.surface)),
        ),
        Positioned(
          right: -8, top: 0, bottom: 0,
          child: Center(child: _Notch(color: scheme.surface)),
        ),
      ],
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 16, height: 16,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Dashed horizontal divider for ticket-style cards.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(builder: (_, c) {
        const dash = 6.0;
        const gap = 4.0;
        final n = (c.maxWidth / (dash + gap)).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Container(
              width: dash, height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        );
      }),
    );
  }
}

class _OfferData {
  const _OfferData({
    required this.emoji, required this.title, required this.sub,
    required this.code, required this.expires, required this.bg,
  });
  final String emoji;
  final String title;
  final String sub;
  final String code;
  final String expires;
  final Color bg;
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.data});
  final _OfferData data;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: TastyRadii.lgRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.bg, borderRadius: TastyRadii.mdRadius,
            ),
            child: Text(data.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.sub} · ',
                      style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: data.expires,
                      style: text.labelMedium?.copyWith(
                        color: TastyColors.brandOrangeDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 4),
                Text(data.code,
                    style: text.labelSmall?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: data.code));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}

