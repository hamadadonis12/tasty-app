import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import 'appearance_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'language_settings_screen.dart';
import 'legal_screen.dart';
import 'notifications_screen.dart';

/// `settings` — real settings hub reachable from the account app-bar gear.
/// Aggregates profile, preferences (language, appearance), notification
/// toggles, and legal. Toggles persist for the session via local state.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailPromos = false;
  bool _orderSounds = true;

  void _push(Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              _SectionLabel('ACCOUNT'),
              _Card([
                _NavTile(
                  icon: Icons.person_outline,
                  title: 'Personal information',
                  value: s.name,
                  onTap: () => _push(const EditProfileScreen()),
                ),
              ]),
              _SectionLabel('PREFERENCES'),
              _Card([
                _NavTile(
                  icon: Icons.language,
                  title: 'Language',
                  value: s.language.label,
                  onTap: () => _push(const LanguageSettingsScreen()),
                ),
                _NavTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  value: s.themeModeLabel,
                  onTap: () => _push(const AppearanceSettingsScreen()),
                ),
              ]),
              _SectionLabel('NOTIFICATIONS'),
              _Card([
                _SwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push notifications',
                  subtitle: 'Order updates and offers',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
                _SwitchTile(
                  icon: Icons.mail_outline,
                  title: 'Email promotions',
                  subtitle: 'Weekly deals and news',
                  value: _emailPromos,
                  onChanged: (v) => setState(() => _emailPromos = v),
                ),
                _SwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'In-app sounds',
                  subtitle: 'Play a sound on order events',
                  value: _orderSounds,
                  onChanged: (v) => setState(() => _orderSounds = v),
                ),
                _NavTile(
                  icon: Icons.tune,
                  title: 'Notification center',
                  onTap: () => _push(const NotificationsScreen()),
                ),
              ]),
              _SectionLabel('ABOUT'),
              _Card([
                _NavTile(
                  icon: Icons.gavel,
                  title: 'Legal & terms',
                  onTap: () => _push(const LegalScreen()),
                ),
                const _NavTile(
                  icon: Icons.info_outline,
                  title: 'App version',
                  value: '2.4.0',
                ),
              ]),
              const SizedBox(height: TastySpacing.stackLg),
              Center(
                child: Text('TastyLife · Made in Kinshasa',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: TastySpacing.stackMd),
      child: Text(label,
          style: text.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card(this.children);
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(children: children),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.title, this.value, this.onTap});
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurface, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: text.bodyLarge)),
            if (value != null)
              Flexible(
                child: Text(value!,
                    style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurface, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.bodyLarge),
                Text(subtitle, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
