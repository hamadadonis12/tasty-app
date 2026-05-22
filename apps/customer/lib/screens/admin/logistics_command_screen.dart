import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `logistics_command` — top-level logistics tabs entry (Live Orders /
/// Fleet / Financials) summarized side-by-side.
class LogisticsCommandScreen extends StatelessWidget {
  const LogisticsCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'live_map',
      title: 'Logistics Command',
      subtitle: 'Cross-city operations · drill down into any pillar',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Pillar(
                    title: 'Live Orders',
                    subtitle: '342 active · 18 delayed',
                    icon: Icons.receipt_long,
                    metric: '12 min',
                    metricLabel: 'AVG ETA',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Pillar(
                    title: 'Fleet',
                    subtitle: '394 drivers · 52% utilization',
                    icon: Icons.directions_bike,
                    metric: '4.9',
                    metricLabel: 'AVG RATING',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Pillar(
                    title: 'Financials',
                    subtitle: '\$1.45M month · +18% YoY',
                    icon: Icons.account_balance,
                    metric: '\$42.1k',
                    metricLabel: 'PAYOUTS TODAY',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Cross-pillar health', style: text.titleMedium),
                      const Spacer(),
                      Text('Last 24h', style: text.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Healthbar(label: 'Order success rate', value: 0.97, scheme: scheme),
                  _Healthbar(label: 'Driver acceptance', value: 0.91, scheme: scheme),
                  _Healthbar(label: 'On-time deliveries', value: 0.88, scheme: scheme),
                  _Healthbar(label: 'Restaurant uptime', value: 0.94, scheme: scheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pillar extends StatelessWidget {
  const _Pillar({required this.title, required this.subtitle, required this.icon, required this.metric, required this.metricLabel});
  final String title;
  final String subtitle;
  final IconData icon;
  final String metric;
  final String metricLabel;
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
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary.withValues(alpha: 0.2),
                child: Icon(icon, color: scheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: text.titleMedium)),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: text.bodySmall),
          const SizedBox(height: 18),
          Text(metricLabel,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.4)),
          Text(metric,
              style: text.displaySmall?.copyWith(color: scheme.primary, fontSize: 32)),
        ],
      ),
    );
  }
}

class _Healthbar extends StatelessWidget {
  const _Healthbar({required this.label, required this.value, required this.scheme});
  final String label;
  final double value;
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
              Text('${(value * 100).toStringAsFixed(0)}%',
                  style: text.labelMedium?.copyWith(
                    color: value >= 0.9 ? TastyColors.success : value >= 0.8 ? scheme.primary : scheme.error,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: TastyRadii.fullRadius,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(
                value >= 0.9 ? TastyColors.success : value >= 0.8 ? scheme.primary : scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
