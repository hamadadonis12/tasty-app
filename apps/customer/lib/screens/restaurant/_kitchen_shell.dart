import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// Common shell for tablet-landscape Kitchen OS screens.
///
/// Left rail with restaurant identity + nav, top header with brand,
/// load chip, drivers-ready chip, chef avatar. Body fills the rest.
class KitchenShell extends StatelessWidget {
  const KitchenShell({
    super.key,
    required this.activeKey,
    required this.title,
    required this.subtitle,
    required this.body,
    this.headerTrailing = const [],
    this.loadLevel = 'Ready',
    this.loadCount = 0,
    this.driversReady = 4,
  });

  final String activeKey;
  final String title;
  final String subtitle;
  final Widget body;
  final List<Widget> headerTrailing;
  final String loadLevel;
  final int loadCount;
  final int driversReady;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: SafeArea(
        child: Row(
          children: [
            // Left rail
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                border: Border(
                  right: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=160&q=80',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Maison Kinshasa',
                                style: text.titleSmall?.copyWith(color: scheme.primary)),
                            Row(
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(
                                    color: TastyColors.success, shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('Open', style: text.labelSmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackLg),
                  for (final n in _nav)
                    _NavRow(icon: n.icon, label: n.label, active: n.key == activeKey),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TastyColors.warningContainer,
                      borderRadius: TastyRadii.lgRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BUSY MODE',
                            style: text.labelSmall?.copyWith(
                              color: TastyColors.onWarningContainer,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            )),
                        Text('+15 min to all ETAs',
                            style: text.labelSmall?.copyWith(color: TastyColors.onWarningContainer)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: text.headlineSmall),
                              Text(subtitle, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        ...headerTrailing.expand((w) => [w, const SizedBox(width: 8)]),
                        _Pill(
                          color: scheme.primary,
                          icon: Icons.local_fire_department,
                          label: 'Load: $loadLevel ($loadCount Active)',
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          color: TastyColors.success,
                          icon: Icons.pedal_bike,
                          label: 'Drivers Ready: $driversReady',
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=120&q=80',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: TastyRadii.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.active});
  final IconData icon;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : null,
        borderRadius: TastyRadii.lgRadius,
      ),
      child: Row(
        children: [
          Icon(icon,
              color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: text.bodyMedium?.copyWith(
                color: active ? scheme.onPrimaryContainer : scheme.onSurface,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _Nav {
  const _Nav(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

const _nav = <_Nav>[
  _Nav('live', 'Live Orders', Icons.notifications_active),
  _Nav('queue', 'Order Queue', Icons.view_kanban),
  _Nav('menu', 'Menu', Icons.menu_book),
  _Nav('inventory', 'Inventory', Icons.inventory_2),
  _Nav('staff', 'Staff', Icons.groups),
  _Nav('analytics', 'Analytics', Icons.insights),
  _Nav('settings', 'Settings', Icons.settings),
];

/// Reusable kitchen-styled card.
class KitchenCard extends StatelessWidget {
  const KitchenCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: child,
    );
  }
}
