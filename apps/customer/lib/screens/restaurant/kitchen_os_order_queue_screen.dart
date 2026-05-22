import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_kitchen_shell.dart';

/// `kitchen_os_order_queue` — denser queue with prep timers, delay flags,
/// and a "New Dispatch" CTA. Mirrors the Stitch reference's secondary
/// view of the kanban.
class KitchenOsOrderQueueScreen extends StatelessWidget {
  const KitchenOsOrderQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KitchenShell(
      activeKey: 'queue',
      title: 'Order Queue',
      subtitle: 'All inbound, in-progress, and ready-for-pickup',
      loadLevel: 'High',
      loadCount: 12,
      headerTrailing: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.bolt, size: 16), label: const Text('Emergency Sync')),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download, size: 16), label: const Text('Export')),
      ],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(
            child: _Lane(
              title: 'New Orders',
              accent: Color(0xFFFF9F1C),
              count: 4,
              cards: [
                _Card(id: '#4092', meta: '2 min ago',
                    items: ['1× Jollof Rice Special', '2× Grilled Tilapia'],
                    flag: 'No onions on Tilapia',
                    cta: 'Start Preparing'),
                _Card(id: '#4093', meta: 'Just now',
                    items: ['3× Suya Skewers', '1× Plantain Fritters'],
                    cta: 'Start Preparing'),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _Lane(
              title: 'Preparing',
              accent: Color(0xFF895100),
              count: 3,
              cards: [
                _Card(id: '#4088', meta: '15 min elapsed',
                    items: ['1× Egusi Soup', '1× Pounded Yam'],
                    delayed: true,
                    cta: 'Mark Ready'),
                _Card(id: '#4090', meta: 'Prep · 8m',
                    items: ['2× Chicken Yassa'],
                    cta: 'Mark Ready'),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _Lane(
              title: 'Ready for Pickup',
              accent: Color(0xFF1F8F4D),
              count: 1,
              cards: [
                _Card(id: '#4085', meta: 'Waiting for Driver: David M.',
                    items: ['1× Family Feast Platter'],
                    cta: 'Dispatch Order',
                    ctaSecondary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Lane extends StatelessWidget {
  const _Lane({required this.title, required this.accent, required this.count, required this.cards});
  final String title;
  final Color accent;
  final int count;
  final List<_Card> cards;
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
            itemBuilder: (_, i) => cards[i],
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: cards.length,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.id, required this.meta, required this.items, required this.cta,
    this.delayed = false, this.flag, this.ctaSecondary = false,
  });
  final String id;
  final String meta;
  final List<String> items;
  final String cta;
  final bool delayed;
  final String? flag;
  final bool ctaSecondary;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenCard(
      child: Stack(
        children: [
          if (delayed)
            Positioned(
              left: -14, top: 0, bottom: 0,
              child: Container(width: 4,
                  decoration: BoxDecoration(color: scheme.error, borderRadius: TastyRadii.smRadius)),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(id, style: text.titleMedium),
                  const Spacer(),
                  if (delayed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer, borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 12, color: scheme.onErrorContainer),
                          const SizedBox(width: 4),
                          Text('Delayed',
                              style: text.labelSmall?.copyWith(
                                color: scheme.onErrorContainer, fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    )
                  else
                    Text(meta, style: text.labelSmall),
                ],
              ),
              if (delayed) Text(meta, style: text.labelSmall),
              const SizedBox(height: 8),
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(it, style: text.bodyMedium),
                ),
              if (flag != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.warning_amber, size: 14, color: TastyColors.warning),
                    const SizedBox(width: 4),
                    Text(flag!, style: text.labelMedium?.copyWith(color: TastyColors.warning)),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: ctaSecondary ? scheme.surfaceContainerHigh : scheme.primaryContainer,
                  foregroundColor: ctaSecondary ? scheme.onSurface : scheme.onPrimaryContainer,
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(cta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
