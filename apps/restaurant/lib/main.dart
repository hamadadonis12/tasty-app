import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const KitchenOsApp());
}

/// TastyLife **Kitchen OS** — the restaurant-side tablet app.
///
/// Designed landscape-first. Phase 0 placeholder: shows the three-column
/// kanban shell from the Stitch reference (`kitchen_os_live_orders`) with
/// empty columns until the API wires up real orders.
class KitchenOsApp extends StatelessWidget {
  const KitchenOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TastyLife Kitchen OS',
      debugShowCheckedModeBanner: false,
      theme: TastyTheme.lightTheme,
      darkTheme: TastyTheme.darkTheme,
      home: const _KitchenOsHome(),
    );
  }
}

class _KitchenOsHome extends StatelessWidget {
  const _KitchenOsHome();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('TastyLife',
                      style: text.titleLarge?.copyWith(color: scheme.primary)),
                  const SizedBox(width: TastySpacing.stackSm),
                  Text('Kitchen OS', style: text.titleLarge),
                  const Spacer(),
                  _LoadPill(label: 'Load: ready', count: 0, color: scheme.primaryContainer),
                ],
              ),
              const SizedBox(height: TastySpacing.stackLg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(child: _Column(title: 'New Orders', accent: Color(0xFFFF9F1C))),
                    SizedBox(width: TastySpacing.gutterCard),
                    Expanded(child: _Column(title: 'Preparing', accent: Color(0xFF895100))),
                    SizedBox(width: TastySpacing.gutterCard),
                    Expanded(child: _Column(title: 'Ready', accent: Color(0xFF1F8F4D))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      padding: const EdgeInsets.all(TastySpacing.gutterCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              const SizedBox(width: TastySpacing.stackSm),
              Text(title, style: text.titleMedium),
              const Spacer(),
              Text('0', style: text.labelMedium),
            ],
          ),
          const SizedBox(height: TastySpacing.stackMd),
          Expanded(
            child: Center(
              child: Text(
                'No orders yet',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadPill extends StatelessWidget {
  const _LoadPill({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: TastyRadii.fullRadius),
      child: Text('$label  ·  $count', style: text.labelMedium),
    );
  }
}
