import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `logistics_command_financials` — gross merchandise value, payouts,
/// settlement queue, partner share.
class LogisticsFinancialsScreen extends StatelessWidget {
  const LogisticsFinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'financial',
      title: 'Financials',
      subtitle: 'GMV, payouts, partner settlement queue',
      actions: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today, size: 16), label: const Text('This week')),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: _Tile(label: 'GMV TODAY', value: '\$42.5k', delta: '+4.2% vs yest', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Tile(label: 'GMV WEEK', value: '\$284k', delta: '+11% WoW', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Tile(label: 'GMV MONTH', value: '\$1.45M', delta: '+18% MoM', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Tile(label: 'PAYOUTS TODAY', value: '\$42.1k', delta: 'Processing', good: true)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _GmvChart()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _RevenueSplit()),
              ],
            ),
            const SizedBox(height: 12),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Payout Batches', style: text.titleMedium),
                  const SizedBox(height: 12),
                  _PayoutRow(id: 'B-RST-001', label: 'Premium Partners (Zone A)', vol: '\$124,500', when: 'Today, 23:00 UTC', status: 'processing'),
                  _PayoutRow(id: 'B-DRV-042', label: 'Fleet Alpha (Instant Pay)', vol: '\$45,200', when: 'Today, 23:30 UTC', status: 'queued'),
                  _PayoutRow(id: 'B-RST-082', label: 'Standard Partners (Zone B)', vol: '\$89,100', when: 'Tomorrow, 08:00', status: 'queued'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.delta, required this.good});
  final String label;
  final String value;
  final String delta;
  final bool good;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall?.copyWith(letterSpacing: 1.4)),
          Text(value, style: text.headlineSmall?.copyWith(color: scheme.primary)),
          Text(delta,
              style: text.labelSmall?.copyWith(
                color: good ? TastyColors.success : scheme.error,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _GmvChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bars = [0.4, 0.55, 0.5, 0.7, 0.8, 0.62, 0.92, 0.78, 0.6, 0.85, 0.95, 0.7];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GMV — last 12 hours', style: text.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in bars)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 130 * h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [scheme.primary, scheme.primaryContainer],
                          ),
                          borderRadius: TastyRadii.smRadius,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
          Text('Revenue Splitting Engine', style: text.titleMedium),
          const SizedBox(height: 12),
          _SplitRow(label: 'Restaurant Partners', percent: 68, color: scheme.primaryContainer, scheme: scheme),
          _SplitRow(label: 'Driver Network', percent: 20, color: scheme.primary, scheme: scheme),
          _SplitRow(label: 'Platform Retained', percent: 12, color: scheme.tertiary, scheme: scheme),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.label, required this.percent, required this.color, required this.scheme});
  final String label;
  final int percent;
  final Color color;
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: text.bodyMedium)),
              Text('$percent%', style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
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

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.id, required this.label, required this.vol, required this.when, required this.status});
  final String id;
  final String label;
  final String vol;
  final String when;
  final String status;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = status == 'processing' ? scheme.primary : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(Icons.account_balance, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: text.bodyMedium), Text(id, style: text.labelSmall)],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text(vol, style: text.titleSmall), Text(when, style: text.labelSmall)],
          ),
        ],
      ),
    );
  }
}
