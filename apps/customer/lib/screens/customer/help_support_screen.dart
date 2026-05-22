import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `help_support` — search field, top FAQs, "Contact us" CTAs (chat,
/// call, email), and "Order issue?" deep link.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.18),
              borderRadius: TastyRadii.xxlRadius,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.support_agent, color: scheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('We\'re here, day & night.', style: text.titleSmall),
                      Text('Average reply time: 90 seconds',
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search the help center…',
              prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Contact us', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Row(
            children: const [
              Expanded(child: _Channel(icon: Icons.chat_bubble, label: 'Live chat', sub: 'Avg 90s')),
              SizedBox(width: 10),
              Expanded(child: _Channel(icon: Icons.call, label: 'Call us', sub: '+243 …')),
              SizedBox(width: 10),
              Expanded(child: _Channel(icon: Icons.mail_outline, label: 'Email', sub: 'support@…')),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Order issue?', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Container(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maison Kinshasa · Today', style: text.titleSmall),
                      Text('2 items · \$17.00 · Delivered',
                          style: text.bodySmall),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Get help')),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Top FAQs', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          for (final q in _faqs)
            ExpansionTile(
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
              title: Text(q.$1, style: text.titleSmall),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(q.$2, style: text.bodyMedium),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

const _faqs = <(String, String)>[
  ('How do I track my order?', 'Open Orders → Live Order Tracking. You\'ll see the driver pin and ETA in real time.'),
  ('What if my order is late?', 'Tap "Get help" on the order. We\'ll credit you on the spot if it\'s more than 15 min past ETA.'),
  ('Can I pay cash?', 'Yes, choose "Cash on delivery" at checkout. Drivers carry change up to 50 000 FC.'),
  ('How do I become a Gold member?', 'Order 10 times in a month or refer 3 friends.'),
];

class _Channel extends StatelessWidget {
  const _Channel({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: scheme.primary, size: 18),
          ),
          const SizedBox(height: 6),
          Text(label, style: text.labelMedium),
          Text(sub, style: text.labelSmall),
        ],
      ),
    );
  }
}
