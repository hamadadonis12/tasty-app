import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_kitchen_shell.dart';

/// `kitchen_os_live_orders` — the real-time kanban: New / Preparing /
/// Ready, with action buttons and prep timers.
class KitchenOsLiveOrdersScreen extends StatelessWidget {
  const KitchenOsLiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KitchenShell(
      activeKey: 'live',
      title: 'Live Orders',
      subtitle: 'Tap an order to advance, drag to reassign',
      loadLevel: 'High',
      loadCount: 12,
      driversReady: 4,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(child: _Column(
            title: 'New Orders',
            accent: Color(0xFFFF9F1C),
            count: 5,
            orders: [
              _Order(id: '#4092', meta: 'Dine-in · Table 12', when: '2 min ago',
                  items: [('2×', 'Poulet Mayo Classic', 'No onions, extra mayo', false), ('1×', 'Frites Madesu', '', false)],
                  cta: 'Start Preparing', ctaPrimary: true),
              _Order(id: '#4093', meta: 'Delivery · Kinshasa Hub', when: 'Just now',
                  items: [('1×', 'Capitaine Grillé', '', false), ('2×', 'Plantains', '', false)],
                  cta: 'Start Preparing', ctaPrimary: false),
            ],
          )),
          SizedBox(width: 16),
          Expanded(child: _Column(
            title: 'Preparing',
            accent: Color(0xFF895100),
            count: 3,
            orders: [
              _Order(id: '#4089', meta: 'Pickup · 10m ETA', when: 'Prep · 6m',
                  items: [('1×', 'Pondu Special', '', true), ('2×', 'Makemba', '', false)],
                  cta: 'Mark Ready', ctaPrimary: true),
              _Order(id: '#4090', meta: 'Dine-in · Table 4', when: '',
                  items: [('1×', 'Liboke de Poisson', '', false)],
                  cta: 'Mark Ready', ctaPrimary: true),
            ],
          )),
          SizedBox(width: 16),
          Expanded(child: _Column(
            title: 'Ready',
            accent: Color(0xFF1F8F4D),
            count: 2,
            orders: [
              _Order(id: '#4085', meta: 'Delivery · Driver Arrived',
                  when: '✓', items: [],
                  cta: 'Hand Off', ctaPrimary: false,
                  badge: '3 items packed'),
            ],
          )),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.title, required this.accent, required this.count, required this.orders});
  final String title;
  final Color accent;
  final int count;
  final List<_Order> orders;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: text.titleMedium),
            const Spacer(),
            Text('$count', style: text.labelMedium),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, i) => orders[i],
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: orders.length,
          ),
        ),
      ],
    );
  }
}

class _Order extends StatelessWidget {
  const _Order({
    required this.id, required this.meta, required this.when, required this.items,
    required this.cta, required this.ctaPrimary, this.badge,
  });
  final String id;
  final String meta;
  final String when;
  final List<(String, String, String, bool)> items;
  final String cta;
  final bool ctaPrimary;
  final String? badge;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(id, style: text.titleSmall),
              const Spacer(),
              if (when.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: TastyColors.errorContainer,
                    borderRadius: TastyRadii.fullRadius,
                  ),
                  child: Text(when,
                      style: text.labelSmall?.copyWith(
                          color: TastyColors.onErrorContainer, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(meta, style: text.labelSmall),
          if (badge != null) ...[
            const SizedBox(height: 8),
            Text(badge!, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...items.map((it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        it.$4 ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16, color: it.$4 ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(it.$1, style: text.labelMedium),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.$2,
                                style: text.bodyMedium?.copyWith(
                                  decoration: it.$4 ? TextDecoration.lineThrough : null,
                                  color: it.$4 ? scheme.onSurfaceVariant : scheme.onSurface,
                                )),
                            if (it.$3.isNotEmpty)
                              Text(it.$3,
                                  style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: ctaPrimary ? scheme.primaryContainer : scheme.surfaceContainerHigh,
              foregroundColor: ctaPrimary ? scheme.onPrimaryContainer : scheme.onSurface,
              minimumSize: const Size.fromHeight(40),
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}
