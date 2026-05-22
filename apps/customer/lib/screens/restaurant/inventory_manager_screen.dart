import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_kitchen_shell.dart';

/// `menu_inventory_manager` — inventory view (counterpart to menu manager):
/// stock levels per item, low-stock alerts, par-level recommendations.
class InventoryManagerScreen extends StatelessWidget {
  const InventoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenShell(
      activeKey: 'inventory',
      title: 'Inventory Levels',
      subtitle: 'Live stock counts · auto-86 below par',
      headerTrailing: [
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Receive Stock')),
      ],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock table
          Expanded(
            flex: 3,
            child: KitchenCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('ITEM', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('STOCK', style: text.labelSmall)),
                        Expanded(flex: 2, child: Text('PAR', style: text.labelSmall)),
                        Expanded(flex: 3, child: Text('STATUS', style: text.labelSmall)),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  for (final s in _stock)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(s.$1, style: text.bodyMedium)),
                          Expanded(flex: 2, child: Text(s.$2, style: text.titleSmall)),
                          Expanded(flex: 2, child: Text(s.$3, style: text.bodyMedium)),
                          Expanded(
                            flex: 3,
                            child: _StatusChip(label: s.$4),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Sidebar: low stock alerts
          Expanded(
            flex: 2,
            child: Column(
              children: [
                KitchenCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: scheme.error, size: 18),
                          const SizedBox(width: 6),
                          Text('Low stock', style: text.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final l in const [('Tilapia', '12 left', 'auto-86 in 4'),
                                              ('Plantains', '8 left', 'auto-86 in 2'),
                                              ('Pondu leaves', '3 left', 'AUTO-86 ACTIVE')])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: scheme.error.withValues(alpha: 0.15),
                                child: Icon(Icons.inventory_2, color: scheme.error, size: 12),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text(l.$1, style: text.bodyMedium), Text(l.$2, style: text.labelSmall)],
                                ),
                              ),
                              Text(l.$3,
                                  style: text.labelSmall?.copyWith(
                                    color: scheme.error, fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                KitchenCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's waste", style: text.titleMedium),
                      const SizedBox(height: 6),
                      Text('\$32.50',
                          style: text.displaySmall?.copyWith(color: scheme.primary)),
                      Text('Below 5% target', style: text.labelMedium),
                    ],
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

const _stock = <(String, String, String, String)>[
  ('Tilapia (whole)', '12', '20', 'low'),
  ('Capitaine fillets', '8', '15', 'low'),
  ('Chicken (whole)', '42', '30', 'ok'),
  ('Plantains', '8', '25', 'critical'),
  ('Pondu leaves', '3', '10', 'critical'),
  ('Rice (kg)', '34', '20', 'ok'),
  ('Cassava flour', '18', '12', 'ok'),
];

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = switch (label) {
      'critical' => scheme.error,
      'low' => TastyColors.warning,
      _ => TastyColors.success,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
