import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `tactical_navigation_mode` — turn-by-turn handoff screen. Big arrow,
/// next instruction, ETA + distance, swipe-up panel with stop info.
class TacticalNavigationScreen extends StatelessWidget {
  const TacticalNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surfaceContainer,
                    scheme.primaryContainer.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          // Big turn instruction card at the top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: Container(
                padding: const EdgeInsets.all(TastySpacing.gutterCard),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: TastyRadii.xlRadius,
                  boxShadow: TastyShadows.glow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.turn_right, color: scheme.onPrimary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In 200 m',
                              style: text.labelMedium?.copyWith(
                                  color: scheme.onPrimary.withValues(alpha: 0.85))),
                          Text('Turn right onto Avenue Kasa-Vubu',
                              style: text.titleMedium?.copyWith(color: scheme.onPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                boxShadow: TastyShadows.sheet,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ETA TO DROPOFF',
                                  style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
                              Text('11 min',
                                  style: text.displaySmall?.copyWith(color: scheme.primary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('DISTANCE', style: text.labelSmall),
                            Text('2.4 km', style: text.titleLarge),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: TastyRadii.lgRadius,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: TastyColors.success.withValues(alpha: 0.15),
                            child: Icon(Icons.person, color: TastyColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Drop off to Merveille', style: text.titleSmall),
                                Text('87 Boulevard du 30 Juin', style: text.bodySmall),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.chat_bubble), onPressed: () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.report),
                            label: const Text('Report issue'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.flag),
                            label: const Text('Arrived'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
