import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `logistics_command_live_orders` — searchable table of all live orders.
class LogisticsLiveOrdersScreen extends StatelessWidget {
  const LogisticsLiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'live_map',
      title: 'Live Order Monitor',
      subtitle: 'Real-time city-wide order tracking',
      actions: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.bolt, size: 16), label: const Text('High Value')),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.schedule, size: 16), label: const Text('Delayed')),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.tune, size: 16), label: const Text('All Filters')),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI strip
          Row(
            children: const [
              Expanded(child: _MiniKpi(label: 'ACTIVE ORDERS', value: '342', delta: '+12% vs last hour', good: true)),
              SizedBox(width: 12),
              Expanded(child: _MiniKpi(label: 'AVG PREP TIME', value: '14 min', delta: '−2m vs avg', good: true)),
              SizedBox(width: 12),
              Expanded(child: _MiniKpi(label: 'DELAYED', value: '18', delta: 'Requires attention', good: false)),
              SizedBox(width: 12),
              Expanded(child: _MiniKpi(label: 'TOTAL VALUE', value: '\$12.4k', delta: 'On target', good: true)),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AdminCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xl)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text('ORDER ID', style: text.labelSmall)),
                        Expanded(flex: 3, child: Text('RESTAURANT', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('CUSTOMER', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('STATUS', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('ETA', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('VALUE', textAlign: TextAlign.right, style: text.labelSmall)),
                        const SizedBox(width: 28),
                      ],
                    ),
                  ),
                  // Rows
                  for (final r in _rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(r.$1, style: text.bodyMedium?.copyWith(color: scheme.primary))),
                          Expanded(flex: 3, child: Text(r.$2, style: text.bodyMedium)),
                          Expanded(flex: 2, child: Text(r.$3, style: text.bodyMedium)),
                          Expanded(flex: 2, child: _StatusBadge(label: r.$4, kind: r.$5)),
                          Expanded(flex: 2, child: Text(r.$6, style: text.bodyMedium)),
                          Expanded(flex: 2, child: Text(r.$7, textAlign: TextAlign.right, style: text.titleSmall)),
                          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text('Showing 1–5 of 342 orders', style: text.labelMedium),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({required this.label, required this.value, required this.delta, required this.good});
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
          const SizedBox(height: 4),
          Text(value, style: text.headlineSmall?.copyWith(color: scheme.primary)),
          const SizedBox(height: 4),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.kind});
  final String label;
  final String kind; // transit | delayed | preparing | arrived
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = switch (kind) {
      'transit' => TastyColors.info,
      'delayed' => scheme.error,
      'preparing' => scheme.primary,
      _ => TastyColors.success,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: TastyRadii.fullRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label.toUpperCase(),
                style: text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

const _rows = <(String, String, String, String, String, String, String)>[
  ('#TL-8892', 'Burger Joint Downtown', 'Sarah J.', 'In transit', 'transit', '12 mins', '\$42.50'),
  ('#TL-8891', 'Spice Route Indian', 'Michael T.', 'Delayed', 'delayed', '25 mins', '\$85.00'),
  ('#TL-8890', 'Sushi Master', 'Elena R.', 'Preparing', 'preparing', 'Est. 18m', '\$120.00'),
  ('#TL-8889', 'Green Bowl Salads', 'David W.', 'Preparing', 'preparing', 'Est. 5m', '\$24.00'),
  ('#TL-8888', 'Pizza Paradiso', 'Alex B.', 'Arrived', 'arrived', '——', '\$55.20'),
];
