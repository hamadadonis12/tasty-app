import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `notifications_updates` — grouped (Today / This Week / Earlier).
/// Mix of order events, promos, system updates.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: Text('Mark all read', style: text.labelMedium)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
        children: [
          _SectionLabel('TODAY'),
          _Item(
            icon: Icons.delivery_dining,
            iconBg: scheme.primaryContainer,
            iconFg: scheme.onPrimaryContainer,
            title: 'Jean has picked up your order',
            subtitle: 'From Maison Kinshasa · 19:32',
            unread: true,
          ),
          _Item(
            icon: Icons.local_offer,
            iconBg: TastyColors.successContainer,
            iconFg: TastyColors.onSuccessContainer,
            title: '-30% on Le Grill Premium tonight',
            subtitle: 'Use code TASTY30 · valid until 22:00',
            unread: true,
          ),
          _SectionLabel('THIS WEEK'),
          _Item(
            icon: Icons.star_rounded,
            iconBg: TastyColors.warningContainer,
            iconFg: TastyColors.onWarningContainer,
            title: 'You\'re now a Gold member',
            subtitle: '50 orders unlocked free delivery for a month',
          ),
          _Item(
            icon: Icons.payments,
            iconBg: scheme.surfaceContainerHigh,
            iconFg: scheme.onSurfaceVariant,
            title: 'Wallet top-up of 25 000 FC',
            subtitle: 'Orange Money · receipt sent',
          ),
          _SectionLabel('EARLIER'),
          _Item(
            icon: Icons.restaurant,
            iconBg: scheme.surfaceContainerHigh,
            iconFg: scheme.onSurfaceVariant,
            title: 'New on TastyLife: Sushi Lounge',
            subtitle: 'Limete · opens daily 11am–10pm',
          ),
          _Item(
            icon: Icons.system_update_alt,
            iconBg: scheme.surfaceContainerHigh,
            iconFg: scheme.onSurfaceVariant,
            title: 'New app update available',
            subtitle: 'Tap to install v2.4.0',
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, TastySpacing.stackMd, 0, TastySpacing.stackSm),
      child: Text(label,
          style: text.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    this.unread = false,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final bool unread;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconBg, child: Icon(icon, color: iconFg)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodySmall),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
