import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../state/cart_controller.dart';

/// `notifications_updates` — live log of every notification the user has
/// received, grouped by date (Today / This Week / Earlier).
///
/// Reads from [CartController.notifications], which is appended to on
/// every order-stage transition and seeded with marketing events. As
/// soon as the customer places an order, "Order Placed!" appears here,
/// then "Preparing", "Rider on the way", "Driver arrived", etc.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<String> _readIds = <String>{};

  void _markAllRead(List<String> ids) {
    setState(() => _readIds.addAll(ids));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (ctx, _) => TextButton(
              onPressed: () => _markAllRead(
                CartController.instance.notifications.map((e) => e.id).toList(),
              ),
              child: Text('Mark all read', style: text.labelMedium),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final all = CartController.instance.notifications;
          final now = DateTime.now();
          DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
          final today = startOfDay(now);
          final weekAgo = today.subtract(const Duration(days: 7));

          final todayItems = <NotificationEvent>[];
          final weekItems = <NotificationEvent>[];
          final earlierItems = <NotificationEvent>[];

          for (final n in all) {
            final ts = startOfDay(n.timestamp);
            if (n.isOrderEvent || !ts.isBefore(today)) {
              todayItems.add(n);
            } else if (!ts.isBefore(weekAgo)) {
              weekItems.add(n);
            } else {
              earlierItems.add(n);
            }
          }

          // Sort newest first within each group.
          int byNewest(NotificationEvent a, NotificationEvent b) =>
              b.timestamp.compareTo(a.timestamp);
          todayItems.sort(byNewest);
          weekItems.sort(byNewest);
          earlierItems.sort(byNewest);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            children: [
              _SectionLabel('TODAY'),
              if (todayItems.isEmpty)
                _EmptyNote(
                  text:
                      'No new notifications today.\nPlace an order to get live updates here.',
                )
              else
                for (final n in todayItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Item(
                      event: n,
                      unread: !_readIds.contains(n.id),
                      onTap: () => setState(() => _readIds.add(n.id)),
                    ),
                  ),
              if (weekItems.isNotEmpty) ...[
                _SectionLabel('THIS WEEK'),
                for (final n in weekItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Item(
                      event: n,
                      unread: !_readIds.contains(n.id),
                      onTap: () => setState(() => _readIds.add(n.id)),
                    ),
                  ),
              ],
              if (earlierItems.isNotEmpty) ...[
                _SectionLabel('EARLIER'),
                for (final n in earlierItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Item(
                      event: n,
                      unread: !_readIds.contains(n.id),
                      onTap: () => setState(() => _readIds.add(n.id)),
                    ),
                  ),
              ],
            ],
          );
        },
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

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.event,
    required this.unread,
    required this.onTap,
  });
  final NotificationEvent event;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final icon = IconData(event.iconCodePoint, fontFamily: event.iconFontFamily);
    final isOrder = event.isOrderEvent;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: TastyRadii.xlRadius,
        child: InkWell(
          borderRadius: TastyRadii.xlRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isOrder
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHigh,
                  child: Icon(
                    icon,
                    color: isOrder
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(event.subtitle, style: text.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        _formatRelativeTime(event.timestamp),
                        style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
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
          ),
        ),
      ),
    );
  }

  static String _formatRelativeTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
