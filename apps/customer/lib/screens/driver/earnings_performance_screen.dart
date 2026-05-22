import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `earnings_performance` — driver earnings dashboard: today / week /
/// month tabs, big totals, breakdown by trip type, performance metrics.
class EarningsPerformanceScreen extends StatelessWidget {
  const EarningsPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Earnings'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Today'), Tab(text: 'Week'), Tab(text: 'Month')],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          children: [
            Container(
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
                borderRadius: TastyRadii.xxlRadius,
                boxShadow: TastyShadows.glow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL EARNED',
                      style: text.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 1.4,
                      )),
                  Text('\$842.20',
                      style: text.displayLarge?.copyWith(color: Colors.white, fontSize: 56)),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 0.9), size: 16),
                      const SizedBox(width: 4),
                      Text('+18% vs last week',
                          style: text.bodyMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  Row(
                    children: [
                      _LegendDot(color: Colors.white, label: '52 trips'),
                      const SizedBox(width: 14),
                      _LegendDot(color: Colors.white.withValues(alpha: 0.6), label: '8 tips'),
                      const SizedBox(width: 14),
                      _LegendDot(color: Colors.white.withValues(alpha: 0.4), label: '3 peaks'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            Text('Breakdown', style: text.titleSmall),
            const SizedBox(height: TastySpacing.stackSm),
            _Breakdown(label: 'Base fare', value: '\$612.50', share: 0.73),
            _Breakdown(label: 'Tips', value: '\$132.10', share: 0.15),
            _Breakdown(label: 'Peak bonuses', value: '\$67.60', share: 0.08),
            _Breakdown(label: 'Promotions', value: '\$30.00', share: 0.04),
            const SizedBox(height: TastySpacing.sectionGap),
            Text('Performance', style: text.titleSmall),
            const SizedBox(height: TastySpacing.stackSm),
            Row(children: const [
              Expanded(child: _Metric(icon: Icons.thumb_up, label: 'Accept rate', value: '93%')),
              SizedBox(width: 10),
              Expanded(child: _Metric(icon: Icons.check_circle, label: 'On-time', value: '97%')),
            ]),
            const SizedBox(height: 10),
            Row(children: const [
              Expanded(child: _Metric(icon: Icons.star_rounded, label: 'Rating', value: '4.9')),
              SizedBox(width: 10),
              Expanded(child: _Metric(icon: Icons.cancel, label: 'Cancellations', value: '2%')),
            ]),
            const SizedBox(height: TastySpacing.sectionGap),
            FilledButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download statement'),
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.95))),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.label, required this.value, required this.share});
  final String label;
  final String value;
  final double share;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: text.bodyLarge)),
              Text(value, style: text.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: TastyRadii.fullRadius,
            child: LinearProgressIndicator(
              value: share,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 8),
          Text(value, style: text.headlineSmall),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }
}
