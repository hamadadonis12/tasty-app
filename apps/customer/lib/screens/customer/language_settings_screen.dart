import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';

/// `language_settings` — working language picker for the launch markets
/// (Français / English / Lingála). Persists the choice in [AppState] so the
/// account screen reflects it. Full string translation is rolled out per
/// screen; the preference is stored and surfaced here.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Language')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final current = AppState.instance.language;
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              Text('Choose your language', style: text.titleSmall),
              const SizedBox(height: TastySpacing.stackSm),
              for (final lang in AppLanguage.values)
                _LanguageOption(
                  lang: lang,
                  selected: current == lang,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    AppState.instance.setLanguage(lang);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Language set to ${lang.label}'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.lang, required this.selected, required this.onTap});
  final AppLanguage lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
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
              Text(lang.flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.label, style: text.titleSmall),
                    Text(lang.nativeSubtitle, style: text.bodySmall),
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
