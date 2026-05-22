import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_kitchen_shell.dart';

/// `staff_productivity_center` — station telemetry, output per cook,
/// "clocked in" sidebar, idle alerts.
class StaffProductivityScreen extends StatelessWidget {
  const StaffProductivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenShell(
      activeKey: 'staff',
      title: 'Staff & Kitchen Analytics',
      subtitle: 'Live shift telemetry · adjust before the dinner rush',
      headerTrailing: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today, size: 16), label: const Text('Morning (08:00 – 14:00)')),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI strip
          Row(
            children: const [
              Expanded(child: _Stat(label: 'ACTIVE STAFF', value: '24', sub: '/28 scheduled')),
              SizedBox(width: 12),
              Expanded(child: _Stat(label: 'AVG STATION PREP', value: '04:12', sub: 'on target')),
              SizedBox(width: 12),
              Expanded(child: _Stat(label: 'ACTIVE STATIONS', value: '6', sub: 'standard load')),
              SizedBox(width: 12),
              Expanded(child: _Stat(label: 'KITCHEN ALERTS', value: '2', sub: 'requires attention', danger: true)),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Station Telemetry', style: text.titleMedium),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.7,
                          ),
                          children: const [
                            _Station(name: 'Grill Station', flag: 'HIGH LOAD', queue: '34', avg: '08:45', staff: '3'),
                            _Station(name: 'Prep Station', flag: '', queue: '12', avg: '02:10', staff: '4'),
                            _Station(name: 'Final Packing & QC', flag: '', queue: '8', avg: '45 sec/bag', staff: '2', narrow: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: KitchenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: scheme.primary, size: 18),
                            const SizedBox(width: 6),
                            Text('Clocked In', style: text.titleMedium),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: TastyColors.successContainer,
                                borderRadius: TastyRadii.fullRadius,
                              ),
                              child: Text('Live Sync',
                                  style: text.labelSmall?.copyWith(
                                    color: TastyColors.onSuccessContainer,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final m in const [
                          ('Sarah Jenkins', 'Grill', '06:30', '4h 02m'),
                          ('Marcus Chen', 'Grill', '07:15', '3h 17m'),
                          ('David Ross', 'Prep', '06:45', '3h 47m'),
                          ('Elena Rostova', 'Prep', '08:00', '2h 32m'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage(
                                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.$1, style: text.bodyMedium),
                                      Text('${m.$2} Station', style: text.labelSmall),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(m.$3, style: text.labelMedium?.copyWith(color: scheme.primary)),
                                    Text(m.$4, style: text.labelSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('VIEW FULL ROSTER')),
                      ],
                    ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.sub, this.danger = false});
  final String label;
  final String value;
  final String sub;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
          Text(value,
              style: text.displaySmall?.copyWith(
                color: danger ? scheme.error : scheme.primary,
                fontSize: 28,
              )),
          Text(sub, style: text.labelMedium),
        ],
      ),
    );
  }
}

class _Station extends StatelessWidget {
  const _Station({
    required this.name, required this.flag, required this.queue, required this.avg, required this.staff,
    this.narrow = false,
  });
  final String name;
  final String flag;
  final String queue;
  final String avg;
  final String staff;
  final bool narrow;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: text.titleSmall),
              const Spacer(),
              if (flag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer, borderRadius: TastyRadii.fullRadius,
                  ),
                  child: Text(flag,
                      style: text.labelSmall?.copyWith(
                        color: scheme.onErrorContainer, fontWeight: FontWeight.w700,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Cell(label: 'Queue Depth', value: queue, unit: narrow ? 'pending' : 'Items')),
              Expanded(child: _Cell(label: 'Avg Output Time', value: avg, unit: '')),
              Expanded(child: _Cell(label: 'Assigned Crew', value: staff, unit: '')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelSmall),
        Text(value, style: text.titleMedium?.copyWith(color: scheme.primary)),
        if (unit.isNotEmpty) Text(unit, style: text.labelSmall),
      ],
    );
  }
}
