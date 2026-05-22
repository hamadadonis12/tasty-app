import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// Common shell for all admin (LogisAFRICA) screens: dark sidebar nav
/// + content area. Wrap any admin screen body with this to get
/// consistent chrome.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.activeKey,
    required this.title,
    required this.subtitle,
    required this.body,
    this.actions = const [],
  });

  final String activeKey;
  final String title;
  final String subtitle;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TastyTheme.darkTheme,
      child: Builder(builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final text = Theme.of(ctx).textTheme;
        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: Row(
              children: [
                // ---------- Sidebar ----------
                Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    border: Border(
                      right: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: scheme.primary, shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.bolt, color: scheme.onPrimary, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LogisAFRICA',
                                      style: text.titleMedium?.copyWith(color: scheme.primary)),
                                  Text('Operational Hub', style: text.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TastySpacing.stackLg),
                      for (final item in _navItems)
                        _NavItem(
                          icon: item.icon,
                          label: item.label,
                          active: item.key == activeKey,
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: TastyRadii.lgRadius,
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin User', style: text.labelMedium),
                                  Text('TL-ADM-01', style: text.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ---------- Main ----------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                                  Text(subtitle,
                                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            ...actions.expand((w) => [w, const SizedBox(width: 8)]),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: TastyColors.successContainer,
                                borderRadius: TastyRadii.fullRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: TastyColors.success, shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('LIVE SYSTEM SYNC',
                                      style: text.labelSmall?.copyWith(
                                        color: TastyColors.onSuccessContainer,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active});
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
        color: active ? scheme.primaryContainer.withValues(alpha: 0.18) : null,
        borderRadius: TastyRadii.lgRadius,
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? scheme.primary : scheme.onSurfaceVariant, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: text.bodyMedium?.copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _AdminNav {
  const _AdminNav(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

const _navItems = <_AdminNav>[
  _AdminNav('command', 'Fleet Command', Icons.dashboard),
  _AdminNav('live_map', 'Real-time Map', Icons.map),
  _AdminNav('financial', 'Financial Intelligence', Icons.assessment),
  _AdminNav('drivers', 'Driver Network', Icons.directions_bike),
  _AdminNav('alerts', 'Tactical Alerts', Icons.notifications_active),
  _AdminNav('config', 'System Config', Icons.settings),
];

/// Reusable dark-themed card.
class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: TastyRadii.xlRadius,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}
