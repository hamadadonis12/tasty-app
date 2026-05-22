import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `logistics_command_fleet_overview` — fleet utilization, top drivers,
/// idle drivers, scheduled shifts.
class LogisticsFleetScreen extends StatelessWidget {
  const LogisticsFleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AdminShell(
      activeKey: 'drivers',
      title: 'Fleet Overview',
      subtitle: 'Driver activity, utilization, and scheduling',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPIs
            Row(
              children: const [
                Expanded(child: _Stat(label: 'TOTAL FLEET', value: '758', sub: 'across 4 zones')),
                SizedBox(width: 12),
                Expanded(child: _Stat(label: 'ONLINE NOW', value: '394', sub: '52% utilization')),
                SizedBox(width: 12),
                Expanded(child: _Stat(label: 'IDLE > 10m', value: '23', sub: 'Need dispatch')),
                SizedBox(width: 12),
                Expanded(child: _Stat(label: 'AVG RATING', value: '4.87', sub: 'Last 30 days')),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _ZoneUtilization()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _IdleDrivers()),
              ],
            ),
            const SizedBox(height: 12),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Scheduled Shifts · Tonight', style: text.titleMedium),
                      const Spacer(),
                      OutlinedButton(onPressed: () {}, child: const Text('Manage')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final s in _shifts)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80')),
                          const SizedBox(width: 10),
                          Expanded(child: Text(s.$1, style: text.bodyMedium)),
                          Text(s.$2, style: text.labelMedium),
                          const SizedBox(width: 12),
                          _ZoneChip(label: s.$3),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.sub});
  final String label;
  final String value;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall?.copyWith(letterSpacing: 1.4)),
          Text(value, style: text.headlineSmall?.copyWith(color: scheme.primary)),
          Text(sub, style: text.labelSmall),
        ],
      ),
    );
  }
}

class _ZoneUtilization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final zones = const [('Gombe', 0.72), ('Lingwala', 0.61), ('Kasa-Vubu', 0.55), ('Limete', 0.48)];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Utilization by zone', style: text.titleMedium),
          const SizedBox(height: 12),
          for (final z in zones)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(z.$1, style: text.bodyMedium)),
                      Text('${(z.$2 * 100).toStringAsFixed(0)}%',
                          style: text.labelMedium?.copyWith(color: scheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: TastyRadii.fullRadius,
                    child: LinearProgressIndicator(
                      value: z.$2,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
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

class _IdleDrivers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final list = const [('Jean K.', 'Idle 18m', 'Gombe'), ('Paul M.', 'Idle 22m', 'Lingwala'), ('David W.', 'Idle 14m', 'Limete')];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: scheme.error, size: 18),
              const SizedBox(width: 6),
              Text('Idle drivers', style: text.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          for (final d in list)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.error.withValues(alpha: 0.15),
                    child: Icon(Icons.person, color: scheme.error, size: 12),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(d.$1, style: text.bodyMedium)),
                  Text(d.$2, style: text.labelMedium),
                  const SizedBox(width: 12),
                  Text(d.$3, style: text.labelMedium?.copyWith(color: scheme.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.18),
        borderRadius: TastyRadii.fullRadius,
      ),
      child: Text(label,
          style: text.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
    );
  }
}

const _shifts = <(String, String, String)>[
  ('Jean Kabila', '18:00 – 02:00', 'Gombe'),
  ('Merveille K.', '19:00 – 23:00', 'Lingwala'),
  ('David Mwamba', '20:00 – 04:00', 'Kasa-Vubu'),
  ('Sarah Lubaki', '17:00 – 01:00', 'Limete'),
];
