import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `financial_intelligence_risk` — settlement & fraud intel: gross
/// processing volume, payout volume, AI-flagged anomalies, payout batches.
class FinancialIntelligenceScreen extends StatelessWidget {
  const FinancialIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'financial',
      title: 'Settlement & Fraud Intel',
      subtitle: 'Real-time analysis of payout batches, revenue distribution, and AI-flagged anomalous transactions',
      actions: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.sync, size: 16), label: const Text('LIVE SYSTEM SYNC')),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: _BigStat(label: 'GROSS PROCESSING VOL', value: '\$1,452,090', kind: 'normal')),
                SizedBox(width: 12),
                Expanded(child: _BigStat(label: 'PARTNER/DRIVER PAYOUTS', value: '\$340,500', kind: 'normal')),
                SizedBox(width: 12),
                Expanded(child: _BigStat(label: 'VALUE AT RISK (AI)', value: '\$42,100', kind: 'danger')),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _RevenueSplit()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _RiskMonitor()),
              ],
            ),
            const SizedBox(height: 12),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Upcoming Payout Batches', style: text.titleMedium),
                      const Spacer(),
                      OutlinedButton(onPressed: () {}, child: const Text('Restaurants')),
                      const SizedBox(width: 6),
                      OutlinedButton(onPressed: () {}, child: const Text('Drivers')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final b in _batches)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(b.$1, style: text.titleSmall)),
                          Expanded(flex: 4, child: Text(b.$2, style: text.bodyMedium)),
                          Expanded(flex: 2, child: Text(b.$3, style: text.titleSmall)),
                          Expanded(flex: 3, child: Text(b.$4, style: text.bodyMedium)),
                          _StatusChip(label: b.$5),
                        ],
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

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value, required this.kind});
  final String label;
  final String value;
  final String kind;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = kind == 'danger' ? scheme.error : scheme.primary;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall?.copyWith(letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text(value, style: text.displaySmall?.copyWith(color: color, fontSize: 32)),
        ],
      ),
    );
  }
}

class _RevenueSplit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Revenue Splitting Engine', style: text.titleMedium),
              const Spacer(),
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                child: Text('100%', style: text.labelMedium?.copyWith(color: scheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Row(label: 'Restaurant Partners', percent: 68, value: '\$986k', color: scheme.primaryContainer, scheme: scheme),
          _Row(label: 'Driver Network', percent: 20, value: '\$290k', color: scheme.primary, scheme: scheme),
          _Row(label: 'Platform Retained', percent: 12, value: '\$176k', color: scheme.tertiary, scheme: scheme),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.percent, required this.value, required this.color, required this.scheme});
  final String label;
  final int percent;
  final String value;
  final Color color;
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: text.bodyMedium)),
              Text('$percent%', style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              Text(value, style: text.labelMedium),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: TastyRadii.fullRadius,
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final flags = const [
      ('TX-905A-01', 'Velocity Spike Detected', 'multi-restaurant repeated card hits', '\$1,240.00'),
      ('TX-440B-08', 'Geo-Location Mismatch', 'card present 800 km away from order', '\$450.00'),
      ('TX-810C-22', 'Account Takeover Risk', 'login from new IP + password change', '\$320.00'),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: scheme.error, size: 18),
              const SizedBox(width: 6),
              Text('AI Risk Monitor', style: text.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: scheme.error.withValues(alpha: 0.2), borderRadius: TastyRadii.fullRadius),
                child: Text('LIVE FEED',
                    style: text.labelSmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final f in flags)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.06),
                  borderRadius: TastyRadii.lgRadius,
                  border: Border.all(color: scheme.error.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(f.$1, style: text.labelSmall?.copyWith(color: scheme.error, letterSpacing: 1.2)),
                        const Spacer(),
                        Text(f.$4, style: text.labelMedium?.copyWith(color: scheme.error)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(f.$2, style: text.titleSmall),
                    Text(f.$3, style: text.bodySmall),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          TextButton(onPressed: () {}, child: const Text('VIEW ALL FLAGS')),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = label == 'Processing' ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: TastyRadii.fullRadius),
      child: Text(label, style: text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

const _batches = <(String, String, String, String, String)>[
  ('B-RST-001', 'Premium Partners (Zone A)', '\$124,500', 'Today, 23:00 UTC', 'Processing'),
  ('B-DRV-042', 'Fleet Alpha (Instant Pay)', '\$45,200', 'Today, 23:30 UTC', 'Queued'),
  ('B-RST-082', 'Standard Partners (Zone B)', '\$89,100', 'Tomorrow, 08:00', 'Queued'),
];
