import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `tastylife_design_system_ui_kit` — visual catalog of the live design
/// tokens. Color palette, typography ramp, spacing scale, radii, shadows,
/// component samples.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Design System'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          Text('TastyLife UI Kit',
              style: text.displaySmall?.copyWith(color: scheme.primary)),
          const SizedBox(height: 4),
          Text('Luxe-Functional · Material 3 · sourced from the Stitch tokens.',
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Color palette'),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _Swatch(name: 'Primary', hex: '#895100', color: TastyColors.primary),
              _Swatch(name: 'Primary Container', hex: '#FF9F1C', color: TastyColors.primaryContainer),
              _Swatch(name: 'Background', hex: '#FCF9F8', color: TastyColors.background, light: true),
              _Swatch(name: 'On Surface', hex: '#1C1B1B', color: TastyColors.onSurface),
              _Swatch(name: 'Success', hex: '#1F8F4D', color: TastyColors.success),
              _Swatch(name: 'Warning', hex: '#B36B00', color: TastyColors.warning),
              _Swatch(name: 'Error', hex: '#BA1A1A', color: TastyColors.error),
              _Swatch(name: 'Outline', hex: '#877462', color: TastyColors.outline),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Typography'),
          _TypeSample(label: 'Display Large · Inter 56/700', style: text.displayLarge),
          _TypeSample(label: 'Headline Small · Inter 24/700', style: text.headlineSmall),
          _TypeSample(label: 'Title Medium · Inter 18/600', style: text.titleMedium),
          _TypeSample(label: 'Body Large · Plus Jakarta Sans 16/400', style: text.bodyLarge),
          _TypeSample(label: 'Label Medium · Plus Jakarta Sans 12/500', style: text.labelMedium),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Spacing scale (8pt)'),
          for (final s in const [
            ('unit · 8', TastySpacing.unit),
            ('stack-sm · 8', TastySpacing.stackSm),
            ('stack-md · 16', TastySpacing.stackMd),
            ('gutter-card · 20', TastySpacing.gutterCard),
            ('margin-page · 24', TastySpacing.marginPage),
            ('stack-lg · 32', TastySpacing.stackLg),
            ('section-gap · 48', TastySpacing.sectionGap),
          ])
            _SpacingRow(label: s.$1, value: s.$2, scheme: scheme),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Radii'),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _RadiusChip(label: 'xs · 4', radius: TastyRadii.xs),
              _RadiusChip(label: 'sm · 8', radius: TastyRadii.sm),
              _RadiusChip(label: 'md · 12', radius: TastyRadii.md),
              _RadiusChip(label: 'lg · 16', radius: TastyRadii.lg),
              _RadiusChip(label: 'xl · 24', radius: TastyRadii.xl),
              _RadiusChip(label: 'xxl · 32', radius: TastyRadii.xxl),
              _RadiusChip(label: 'full', radius: 999),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Shadows'),
          Row(
            children: [
              Expanded(child: _ShadowCard(label: 'ambient', shadows: TastyShadows.ambient)),
              const SizedBox(width: 12),
              Expanded(child: _ShadowCard(label: 'glow', shadows: TastyShadows.glow)),
              const SizedBox(width: 12),
              Expanded(child: _ShadowCard(label: 'sheet', shadows: TastyShadows.sheet)),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Buttons'),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              TextButton(onPressed: () {}, child: const Text('Text')),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          _Section(label: 'Chips'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              Chip(label: const Text('Default')),
              ActionChip(label: const Text('Action'), onPressed: () {}),
              FilterChip(label: const Text('Filter'), selected: true, onSelected: (_) {}),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: TastyColors.successContainer,
                  borderRadius: TastyRadii.fullRadius,
                ),
                child: Text('Custom status',
                    style: text.labelMedium?.copyWith(
                      color: TastyColors.onSuccessContainer,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: TastySpacing.stackMd),
      child: Text(label.toUpperCase(),
          style: text.labelSmall?.copyWith(
            color: scheme.primary,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.hex, required this.color, this.light = false});
  final String name;
  final String hex;
  final Color color;
  final bool light;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: TastyRadii.lgRadius,
                border: light ? Border.all(color: scheme.outlineVariant) : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: text.titleSmall),
          Text(hex, style: text.labelSmall),
        ],
      ),
    );
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample({required this.label, required this.style});
  final String label;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall),
          Text('The quick brown fox jumps over the lazy dog.', style: style),
        ],
      ),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.label, required this.value, required this.scheme});
  final String label;
  final double value;
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: text.labelMedium)),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: TastyRadii.smRadius),
              child: FractionallySizedBox(
                widthFactor: (value / 48).clamp(0, 1),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: TastyRadii.smRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.label, required this.radius});
  final String label;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(label, style: text.labelSmall),
    );
  }
}

class _ShadowCard extends StatelessWidget {
  const _ShadowCard({required this.label, required this.shadows});
  final String label;
  final List<BoxShadow> shadows;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: shadows,
      ),
      alignment: Alignment.center,
      child: Text(label, style: text.titleSmall),
    );
  }
}
