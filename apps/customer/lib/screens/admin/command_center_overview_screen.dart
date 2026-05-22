import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_admin_shell.dart';

/// `command_center_overview` — admin home: KPI strip, fleet velocity bar
/// chart, top performers, critical alerts panel.
class CommandCenterOverviewScreen extends StatelessWidget {
  const CommandCenterOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeKey: 'command',
      title: 'Command Center',
      subtitle: 'Real-time operational overview · Kinshasa hub',
      actions: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download, size: 16), label: const Text('Export')),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI strip
            Row(
              children: const [
                Expanded(child: _Kpi(label: 'LIVE ORDERS', value: '1,482', delta: '+12% vs last hour', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Kpi(label: 'ACTIVE DRIVERS', value: '394', delta: '52% utilization', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Kpi(label: 'TODAY\'S REVENUE', value: '\$42.5k', delta: '+4.2% vs yesterday', good: true)),
                SizedBox(width: 12),
                Expanded(child: _Kpi(label: 'AVG PREP TIME', value: '14 min', delta: '−2m vs avg', good: true)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _FleetTelemetry()),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: _CriticalAlerts()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _FulfillmentVelocity()),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: _TopPerformers()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.delta, required this.good});
  final String label;
  final String value;
  final String delta;
  final bool good;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text(value,
              style: text.displaySmall?.copyWith(color: scheme.primary, fontSize: 36)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(good ? Icons.trending_up : Icons.trending_down,
                  color: good ? TastyColors.success : scheme.error, size: 14),
              const SizedBox(width: 4),
              Text(delta,
                  style: text.labelSmall?.copyWith(
                    color: good ? TastyColors.success : scheme.error,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _FleetTelemetry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: scheme.primary, size: 16),
              const SizedBox(width: 6),
              Text('Live Fleet Telemetry', style: text.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: TastyRadii.fullRadius,
                ),
                child: Text('Filters', style: text.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.6),
                      borderRadius: TastyRadii.lgRadius,
                    ),
                  ),
                ),
                Positioned(top: 60, left: 80, child: _Dot(scheme: scheme, color: TastyColors.info)),
                Positioned(top: 100, left: 220, child: _Dot(scheme: scheme, color: TastyColors.success)),
                Positioned(top: 140, left: 320, child: _Dot(scheme: scheme, color: scheme.primary, big: true)),
                Positioned(top: 80, right: 80, child: _Dot(scheme: scheme, color: TastyColors.warning)),
                Positioned(top: 160, right: 160, child: _Dot(scheme: scheme, color: scheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.scheme, required this.color, this.big = false});
  final ColorScheme scheme;
  final Color color;
  final bool big;
  @override
  Widget build(BuildContext context) {
    final size = big ? 14.0 : 10.0;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)],
      ),
    );
  }
}

class _CriticalAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final alerts = const [
      ('SYS-ERR-002', 'Driver disconnected during active high-value transport.'),
      ('TRAFFIC-WARN', 'Severe congestion detected on Route 4A. 12 active deliveries impacted.'),
      ('REST-BLY-04', 'Partner Burger Hub reporting 30m+ prep delays.'),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: scheme.error, size: 16),
              const SizedBox(width: 6),
              Text('Critical Alerts', style: text.titleMedium),
              const Spacer(),
              Container(
                width: 22, height: 22, alignment: Alignment.center,
                decoration: BoxDecoration(color: scheme.error, shape: BoxShape.circle),
                child: Text('3', style: text.labelSmall?.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final a in alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.4),
                  borderRadius: TastyRadii.lgRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.$1, style: text.labelSmall?.copyWith(color: scheme.primary, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(a.$2, style: text.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FulfillmentVelocity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bars = [0.5, 0.62, 0.78, 0.55, 0.72, 0.95, 0.6, 0.7, 0.85, 0.92, 0.6, 0.45];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Fulfillment Velocity', style: text.titleMedium),
              const Spacer(),
              Text('Actual', style: text.labelSmall?.copyWith(color: scheme.primary)),
              const SizedBox(width: 10),
              Text('Target', style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in bars)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 150 * h,
                        decoration: BoxDecoration(
                          color: h > 0.85 ? scheme.primary : scheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: TastyRadii.smRadius,
                        ),
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

class _TopPerformers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final performers = const [
      ('PRT-021', '1.2k', '98.8%'),
      ('PRT-088', '950', '97.4%'),
      ('PRT-002', '720', '96.1%'),
      ('PRT-043', '690', '94.7%'),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Performers', style: text.titleMedium),
          const SizedBox(height: 4),
          Text('By completion rate', style: text.labelSmall),
          const SizedBox(height: 10),
          for (final p in performers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.primaryContainer.withValues(alpha: 0.2),
                    child: Icon(Icons.pedal_bike, color: scheme.primary, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p.$1, style: text.bodyMedium)),
                  Text(p.$2, style: text.labelMedium),
                  const SizedBox(width: 12),
                  Text(p.$3,
                      style: text.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
