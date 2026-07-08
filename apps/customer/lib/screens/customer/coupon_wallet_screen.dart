import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';

/// `AppCoupons` from the v2 design — Offers & coupons wallet.
///
/// Apply-code row → tab chips → big hand-picked dark hero coupon (with the
/// signature ticket notches) → list of smaller offers. DRC-localized to FC
/// currency and Kinshasa restaurant names.
class CouponWalletScreen extends StatefulWidget {
  const CouponWalletScreen({super.key});

  @override
  State<CouponWalletScreen> createState() => _CouponWalletScreenState();
}

class _CouponWalletScreenState extends State<CouponWalletScreen> {
  final _codeCtrl = TextEditingController();
  String _activeFilter = 'For you';

  /// Demo promo codes the customer can apply during testing.
  static const Map<String, double> _validCodes = {
    'WKND30': 8.00,
    'BIENVENU30': 5.00,
    'LIVRAISON': 2.00,
    'BISSAP2': 3.00,
    'TARDIF15': 4.50,
    'TASTY30': 6.00,
  };

  static const _allOffers = <_OfferData>[
    _OfferData(
      emoji: '🎉',
      title: '5 000 FC off first order',
      sub: 'Min 25 000 FC · new customers',
      code: 'BIENVENU30',
      expires: '5 days left',
      bg: TastyColors.brandOrange,
      tags: ['New customer'],
    ),
    _OfferData(
      emoji: '🚀',
      title: 'Free delivery · 7 days',
      sub: 'Maison Kinshasa or Mama Lina',
      code: 'LIVRAISON',
      expires: 'Until 31 May',
      bg: TastyColors.brandInk,
      tags: ['For you', 'Expiring'],
    ),
    _OfferData(
      emoji: '☕',
      title: 'Buy 1 get 1 Bissap',
      sub: 'Mama Lina only',
      code: 'BISSAP2',
      expires: '2 days left',
      bg: Color(0xFFD93B3B),
      tags: ['For you', 'Expiring'],
    ),
    _OfferData(
      emoji: '🌃',
      title: '15% late-night specials',
      sub: 'Orders after 22:00',
      code: 'TARDIF15',
      expires: 'Weekends',
      bg: Color(0xFF6B4C93),
      tags: ['For you'],
    ),
  ];

  List<_OfferData> get _filteredOffers {
    if (_activeFilter == 'All') return _allOffers;
    return _allOffers.where((o) => o.tags.contains(_activeFilter)).toList();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _applyCode(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) {
      _toast('Enter a code first.');
      return;
    }
    final amount = _validCodes[code];
    if (amount == null) {
      _toast('Code "$code" is not valid or has expired.');
      return;
    }
    CartController.instance.applyDiscount(amount);
    _toast('Promo $code applied · -\$${amount.toStringAsFixed(2)}');
    _codeCtrl.clear();
    HapticFeedback.mediumImpact();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

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
      body: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              // Code apply row
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
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
                      child: TextField(
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: _applyCode,
                        decoration: const InputDecoration(
                          hintText: 'WKND30, BIENVENU30…',
                          isDense: true,
                          border: InputBorder.none,
                        ),
                        style: text.bodyMedium,
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _applyCode(_codeCtrl.text),
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
              const SizedBox(height: 16),
              
              // Loyalty Points Card (Deducts discounts on checkout!)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [TastyColors.brandOrange, Colors.orangeAccent],
                  ),
                  borderRadius: TastyRadii.xlRadius,
                  boxShadow: TastyShadows.glow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: TastyColors.brandInk, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Loyalty Balance: 12,450 pts',
                          style: text.titleMedium?.copyWith(
                            color: TastyColors.brandInk,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Redeem points for instant discounts on your checkout:',
                      style: text.bodySmall?.copyWith(color: TastyColors.brandInk.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 12),
                    _buildPointsOption(context, '1,000 pts for \$5.00 Off', 5.0),
                    const SizedBox(height: 8),
                    _buildPointsOption(context, '2,000 pts for \$10.00 Off', 10.0),
                    const SizedBox(height: 8),
                    _buildPointsOption(context, '3,000 pts for \$15.00 Off', 15.0),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips — pick one and the offer list filters live
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in const ['For you', 'All', 'New customer', 'Expiring'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _Chip(
                          label: f,
                          active: _activeFilter == f,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _activeFilter = f);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hand-picked hero coupon (dark with ticket notches) —
              // pinned at the top regardless of filter.
              if (_activeFilter == 'For you' || _activeFilter == 'All') ...[
                _HeroCoupon(onUse: () => _applyCode('WKND30')),
                const SizedBox(height: 12),
              ],

              // Filtered offer list — see _filteredOffers above.
              for (final offer in _filteredOffers) ...[
                _OfferRow(data: offer, onCopy: _toast),
                const SizedBox(height: 10),
              ],
              if (_filteredOffers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No "$_activeFilter" offers right now.',
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPointsOption(BuildContext context, String label, double amount) {
    final isApplied = CartController.instance.discount == amount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: TastyRadii.mdRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (isApplied) {
                CartController.instance.applyDiscount(0.0);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Points discount removed.'),
                ));
              } else {
                CartController.instance.applyDiscount(amount);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Loyalty discount of \$${amount.toStringAsFixed(2)} applied successfully!'),
                ));
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isApplied ? Colors.grey : TastyColors.brandInk,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(isApplied ? 'Applied' : 'Redeem'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: active ? TastyColors.brandInk : scheme.surfaceContainerLow,
      borderRadius: TastyRadii.fullRadius,
      child: InkWell(
        borderRadius: TastyRadii.fullRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(label,
              style: text.labelMedium?.copyWith(
                color: active ? Colors.white : scheme.onSurface,
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
    );
  }
}

class _HeroCoupon extends StatelessWidget {
  const _HeroCoupon({required this.onUse});
  final VoidCallback onUse;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRES · SUN 31 MAY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(
                              fontFamily: 'JetBrains Mono',
                              color: Colors.white.withValues(alpha: 0.55),
                              letterSpacing: 1.0,
                            )),
                        const SizedBox(height: 3),
                        Text('WKND30',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontFamily: 'JetBrains Mono',
                              color: TastyColors.brandOrange,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      backgroundColor: TastyColors.brandOrange,
                      foregroundColor: TastyColors.brandInk,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(110, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    this.tags = const [],
  });
  final String emoji;
  final String title;
  final String sub;
  final String code;
  final String expires;
  final Color bg;
  /// Which pill-filters this offer should surface under.
  final List<String> tags;
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.data, required this.onCopy});
  final _OfferData data;
  final void Function(String msg) onCopy;
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
              onCopy('Code ${data.code} copied to clipboard');
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

