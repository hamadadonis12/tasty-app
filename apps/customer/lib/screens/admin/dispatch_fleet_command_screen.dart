import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `dispatch_fleet_command` — incident response: pending dispatches,
/// auto-suggested driver match, manual override.
class DispatchFleetCommandScreen extends StatelessWidget {
  const DispatchFleetCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'live_map',
      title: 'Dispatch · Fleet Command',
      subtitle: 'Manual & auto re-routing for stuck orders',
      actions: [
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.bolt, size: 16), label: const Text('Auto-resolve queue')),
      ],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending Dispatches (4)', style: text.titleMedium),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: const [
                      _Incident(
                        orderId: '#TL-8892',
                        reason: 'Driver disconnected mid-trip',
                        when: '2 min ago',
                        severity: 'critical',
                        candidates: ['Jean K. · 0.4 mi', 'Paul M. · 0.8 mi', 'David W. · 1.2 mi'],
                      ),
                      _Incident(
                        orderId: '#TL-8889',
                        reason: 'Restaurant prep > 30 min',
                        when: '5 min ago',
                        severity: 'warning',
                        candidates: ['Alternate restaurant: Pizza Roma · 1.6 mi'],
                      ),
                      _Incident(
                        orderId: '#TL-8881',
                        reason: 'Customer changed address',
                        when: '6 min ago',
                        severity: 'info',
                        candidates: ['Re-route to driver, +2.1 mi'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: scheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text('Auto-Match Suggestion', style: text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: TastyRadii.lgRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reassign #TL-8892 to Jean Kabila',
                            style: text.titleSmall?.copyWith(color: scheme.primary)),
                        Text('0.4 mi away · ETA penalty +6 min · accept rate 96%',
                            style: text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Apply auto-match'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Manual select'),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text('Resolved today: 28', style: text.labelMedium),
                  Text('Avg resolve time: 1m 42s', style: text.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Incident extends StatelessWidget {
  const _Incident({required this.orderId, required this.reason, required this.when, required this.severity, required this.candidates});
  final String orderId;
  final String reason;
  final String when;
  final String severity;
  final List<String> candidates;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = switch (severity) {
      'critical' => scheme.error,
      'warning' => scheme.primary,
      _ => TastyColors.info,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(orderId, style: text.titleSmall?.copyWith(color: scheme.primary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: TastyRadii.fullRadius),
                  child: Text(severity.toUpperCase(),
                      style: text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                Text(when, style: text.labelSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(reason, style: text.bodyMedium),
            const SizedBox(height: 8),
            for (final c in candidates)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.arrow_right_alt, color: scheme.onSurfaceVariant, size: 16),
                    const SizedBox(width: 6),
                    Text(c, style: text.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
