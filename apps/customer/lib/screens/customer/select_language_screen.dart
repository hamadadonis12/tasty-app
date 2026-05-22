import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `select_language` — first-run language picker. Geo-detected city
/// chip up top, four options (Français, English, Lingala, Kikongo),
/// Continue CTA.
class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key, this.onContinue});
  final VoidCallback? onContinue;
  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Detected city pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: TastyRadii.fullRadius,
                    boxShadow: TastyShadows.ambient,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: scheme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text('Detected: Kinshasa, DRC', style: text.labelLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Text('Choose Your\nLanguage',
                  textAlign: TextAlign.center,
                  style: text.displaySmall?.copyWith(height: 1.1)),
              const SizedBox(height: 8),
              Text(
                'Select the language you prefer for your TastyLife experience.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              for (final (i, l) in _languages.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LanguageTile(
                    item: l,
                    selected: _selected == i,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = i);
                    },
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onContinue?.call();
                },
                icon: const SizedBox.shrink(),
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Continue'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lang {
  const _Lang(this.name, this.label, this.flag);
  final String name;
  final String label;
  final String? flag; // null → use initials
}

const _languages = <_Lang>[
  _Lang('Français', 'French', '🇫🇷'),
  _Lang('English', 'English', '🇬🇧'),
  _Lang('Lingala', 'Lingala', null),
  _Lang('Kikongo', 'Kikongo', null),
];

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.item, required this.selected, required this.onTap});
  final _Lang item;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary.withValues(alpha: 0.14),
                child: item.flag != null
                    ? Text(item.flag!, style: const TextStyle(fontSize: 22))
                    : Text(item.name.substring(0, 2),
                        style: text.titleSmall?.copyWith(color: scheme.primary)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: text.titleSmall),
                    Text(item.label, style: text.labelMedium),
                  ],
                ),
              ),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: scheme.primary, shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
