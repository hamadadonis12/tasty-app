import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';

/// `appearance_settings` — working light / dark / system theme switcher.
/// Writes [AppState.themeMode]; the root [MaterialApp] listens and re-themes
/// the whole app instantly.
class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Appearance')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final current = AppState.instance.themeMode;
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              Text('Theme', style: text.titleSmall),
              const SizedBox(height: TastySpacing.stackSm),
              for (final mode in ThemeMode.values)
                _ThemeOption(
                  mode: mode,
                  selected: current == mode,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    AppState.instance.setThemeMode(mode);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.selected, required this.onTap});
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  (IconData, String, String) get _meta => switch (mode) {
        ThemeMode.system => (Icons.brightness_auto, 'System default', 'Follow your device setting'),
        ThemeMode.light => (Icons.light_mode, 'Light', 'Always use the light theme'),
        ThemeMode.dark => (Icons.dark_mode, 'Dark', 'Always use the dark theme'),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (icon, title, sub) = _meta;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.lgRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall),
                    Text(sub, style: text.bodySmall),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
