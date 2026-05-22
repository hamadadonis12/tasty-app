import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `AppSchedule` from the v2 design — modal sheet for scheduling an order.
///
/// ASAP / Schedule toggle → day strip → time-slot grid (with peak + full
/// states) → primary "Schedule for ..." CTA.
class ScheduleOrderScreen extends StatefulWidget {
  const ScheduleOrderScreen({super.key});
  @override
  State<ScheduleOrderScreen> createState() => _ScheduleOrderScreenState();
}

class _ScheduleOrderScreenState extends State<ScheduleOrderScreen> {
  bool _asap = false;
  int _day = 1;
  int _slot = 2;

  static const _days = <(String, String)>[
    ('TODAY', '24'),
    ('TMRW', '25'),
    ('SAT', '26'),
    ('SUN', '27'),
    ('MON', '28'),
    ('TUE', '29'),
  ];
  static const _slots = <(String, _SlotState)>[
    ('11:00 – 11:30', _SlotState.free),
    ('11:30 – 12:00', _SlotState.free),
    ('12:00 – 12:30', _SlotState.selected),
    ('12:30 – 13:00', _SlotState.free),
    ('13:00 – 13:30', _SlotState.free),
    ('13:30 – 14:00', _SlotState.peak),
    ('14:00 – 14:30', _SlotState.free),
    ('14:30 – 15:00', _SlotState.free),
    ('15:00 – 15:30', _SlotState.full),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.55),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(TastyRadii.xxl),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: TastyRadii.fullRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text('When do you want it?', style: text.titleLarge),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _modeCard(
                          title: 'ASAP',
                          sub: '25–40 min',
                          icon: Icons.bolt,
                          selected: _asap,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _asap = true);
                          },
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _modeCard(
                          title: 'Schedule',
                          sub: 'Pick date & time',
                          icon: Icons.schedule,
                          selected: !_asap,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _asap = false);
                          },
                        )),
                      ],
                    ),
                    if (!_asap) ...[
                      const SizedBox(height: 16),
                      Text('SELECT DAY',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _days.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, i) => _dayPill(i),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('TIME SLOT · ${_days[_day].$1.toUpperCase()} ${_days[_day].$2}',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _slots.length,
                        itemBuilder: (_, i) => _slotTile(i),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.maybePop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: TastyColors.brandOrange,
                          foregroundColor: TastyColors.brandInk,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_asap
                            ? 'Order ASAP'
                            : 'Schedule for ${_days[_day].$1} · ${_slots[_slot].$1.split(' – ').first}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard({
    required String title, required String sub, required IconData icon,
    required bool selected, required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? TastyColors.brandOrangeTint : scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.lgRadius,
            border: Border.all(
              color: selected ? TastyColors.brandOrange : scheme.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : scheme.surfaceContainerLow,
                  borderRadius: TastyRadii.smRadius,
                ),
                child: Icon(icon,
                    color: selected ? TastyColors.brandOrangeDeep : scheme.onSurface, size: 18),
              ),
              const SizedBox(height: 8),
              Text(title, style: text.titleSmall),
              Text(sub,
                  style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayPill(int i) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final d = _days[i];
    final selected = i == _day;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _day = i);
      },
      child: Container(
        width: 56,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? TastyColors.brandInk : scheme.surfaceContainerLowest,
          borderRadius: TastyRadii.mdRadius,
          border: Border.all(
            color: selected ? TastyColors.brandInk : scheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(d.$1.toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: selected ? Colors.white.withValues(alpha: 0.7) : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                )),
            Text(d.$2,
                style: text.titleSmall?.copyWith(
                  color: selected ? Colors.white : scheme.onSurface,
                )),
          ],
        ),
      ),
    );
  }

  Widget _slotTile(int i) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final s = _slots[i];
    final state = s.$2;
    final isSelected = i == _slot && state != _SlotState.full;
    final disabled = state == _SlotState.full;
    Color bg = scheme.surfaceContainerLowest;
    Color borderColor = scheme.outlineVariant.withValues(alpha: 0.5);
    Color labelColor = scheme.onSurface;
    if (isSelected) {
      bg = TastyColors.brandOrange;
      borderColor = TastyColors.brandOrange;
      labelColor = TastyColors.brandInk;
    } else if (disabled) {
      bg = scheme.surfaceContainerLow;
      labelColor = scheme.onSurfaceVariant;
    }
    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: disabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                setState(() => _slot = i);
              },
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: TastyRadii.smRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s.$1,
                  style: text.labelSmall?.copyWith(
                    color: labelColor, fontWeight: FontWeight.w700,
                  )),
              if (state == _SlotState.peak)
                Text('⚡ peak',
                    style: text.labelSmall?.copyWith(
                      color: TastyColors.brandOrangeDeep,
                      fontWeight: FontWeight.w700,
                    ))
              else if (state == _SlotState.full)
                Text('full',
                    style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant))
              else if (isSelected)
                Text('Selected',
                    style: text.labelSmall?.copyWith(
                      color: TastyColors.brandInk, fontWeight: FontWeight.w800,
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SlotState { free, selected, peak, full }
