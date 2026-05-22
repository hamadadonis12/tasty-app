import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `incoming_order_offer` — modal-style alternate offer view with two
/// tappable buttons (Accept / Decline) and a clear payout breakdown.
class IncomingOrderOfferScreen extends StatelessWidget {
  const IncomingOrderOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.55),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(TastySpacing.gutterCard),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: TastyRadii.xxlRadius,
                  boxShadow: TastyShadows.sheet,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Countdown ring
                    Center(
                      child: SizedBox(
                        width: 96, height: 96,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 0.65,
                              strokeWidth: 8,
                              backgroundColor: scheme.surfaceContainer,
                              color: scheme.primary,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('7s', style: text.headlineSmall?.copyWith(color: scheme.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    Center(
                      child: Text('New Offer · Express',
                          style: text.titleMedium?.copyWith(color: scheme.primary)),
                    ),
                    const SizedBox(height: TastySpacing.stackLg),
                    _PayoutRow(label: 'Base fare', value: '\$5.00'),
                    _PayoutRow(label: 'Distance · 4.1 mi', value: '\$2.50'),
                    _PayoutRow(label: 'Peak bonus', value: '\$1.00', highlight: true),
                    const Divider(height: 24),
                    _PayoutRow(label: 'Guaranteed', value: '\$8.50', emphasis: true),
                    const SizedBox(height: TastySpacing.stackMd),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.label, required this.value, this.highlight = false, this.emphasis = false});
  final String label;
  final String value;
  final bool highlight;
  final bool emphasis;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = emphasis
        ? text.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)
        : text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: TastyColors.successContainer,
                borderRadius: TastyRadii.fullRadius,
              ),
              child: Text('PEAK',
                  style: text.labelSmall?.copyWith(
                    color: TastyColors.onSuccessContainer,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
