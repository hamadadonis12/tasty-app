import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'screen_catalog.dart';

/// The gallery / index that lists every Stitch screen with its status.
///
/// Tiles for `live` screens are tappable; `wip` and `missing` tiles render
/// dimmed with a status badge so we can see at a glance what's left to do.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  AppSurface _selected = AppSurface.customer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final filtered = screenCatalog.where((s) => s.surface == _selected).toList();
    final live = filtered.where((s) => s.status == ScreenStatus.live).length;
    final wip = filtered.where((s) => s.status == ScreenStatus.wip).length;
    final missing = filtered.where((s) => s.status == ScreenStatus.missing).length;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('TastyLife — Screen Gallery'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Surface tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TastySpacing.marginPage,
              TastySpacing.stackSm,
              TastySpacing.marginPage,
              TastySpacing.stackMd,
            ),
            child: Wrap(
              spacing: 8,
              children: AppSurface.values.map((s) {
                final selected = s == _selected;
                return ChoiceChip(
                  label: Text(_surfaceLabel(s)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = s),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            child: Row(
              children: [
                _StatusBadge(label: '$live live', color: TastyColors.successContainer, textColor: TastyColors.onSuccessContainer),
                const SizedBox(width: 8),
                _StatusBadge(label: '$wip WIP', color: TastyColors.warningContainer, textColor: TastyColors.onWarningContainer),
                const SizedBox(width: 8),
                _StatusBadge(label: '$missing missing', color: scheme.surfaceContainerHigh, textColor: scheme.onSurfaceVariant),
                const Spacer(),
                Text('${filtered.length} screens', style: text.labelMedium),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.stackMd),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                TastySpacing.marginPage,
                0,
                TastySpacing.marginPage,
                TastySpacing.sectionGap,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: TastySpacing.gutterCard,
                crossAxisSpacing: TastySpacing.gutterCard,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (_, i) => _ScreenTile(entry: filtered[i]),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }

  String _surfaceLabel(AppSurface s) => switch (s) {
        AppSurface.customer => 'Customer',
        AppSurface.driver => 'Driver',
        AppSurface.restaurant => 'Restaurant',
        AppSurface.admin => 'Admin',
      };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: TastyRadii.fullRadius),
      child: Text(label,
          style: text.labelSmall?.copyWith(color: textColor, fontWeight: FontWeight.w700)),
    );
  }
}

class _ScreenTile extends StatelessWidget {
  const _ScreenTile({required this.entry});
  final ScreenEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final live = entry.status == ScreenStatus.live;
    final badge = switch (entry.status) {
      ScreenStatus.live => ('LIVE', TastyColors.successContainer, TastyColors.onSuccessContainer),
      ScreenStatus.wip => ('WIP', TastyColors.warningContainer, TastyColors.onWarningContainer),
      ScreenStatus.missing => ('MISSING', scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
    };

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: live && entry.builder != null
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: entry.builder!),
                )
            : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          padding: const EdgeInsets.all(TastySpacing.stackMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: live
                        ? scheme.primaryContainer.withValues(alpha: 0.15)
                        : scheme.surfaceContainer,
                    borderRadius: TastyRadii.lgRadius,
                  ),
                  child: Icon(
                    live ? Icons.smartphone : Icons.image_outlined,
                    color: live ? scheme.primary : scheme.onSurfaceVariant,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: TastySpacing.stackMd),
              Text(entry.title,
                  style: text.titleSmall,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(entry.slug,
                  style: text.labelSmall,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: TastySpacing.stackSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badge.$2, borderRadius: TastyRadii.fullRadius),
                child: Text(badge.$1,
                    style: text.labelSmall?.copyWith(
                      color: badge.$3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
