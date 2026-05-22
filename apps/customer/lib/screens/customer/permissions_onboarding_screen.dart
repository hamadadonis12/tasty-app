import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `permissions_onboarding` — single-screen permissions primer. Hero
/// illustration (scooter+map), two toggle cards (Location, Notifications),
/// Continue + Skip.
class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key, this.onContinue, this.onSkip});
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;
  @override
  State<PermissionsOnboardingScreen> createState() => _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState extends State<PermissionsOnboardingScreen> {
  bool _location = true;
  bool _notifications = false;

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
              const SizedBox(height: TastySpacing.stackLg),
              // Circular hero "sticker"
              Center(
                child: Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7CFCB), // soft teal background
                    shape: BoxShape.circle,
                    boxShadow: TastyShadows.ambient,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.delivery_dining,
                        color: scheme.primary, size: 96,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Text('Precision Delivery',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'To provide you with surgical ETA accuracy and real-time '
                'culinary updates, we need a few permissions.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              _PermissionTile(
                icon: Icons.location_on,
                title: 'Enable Location',
                sub: 'For precise courier tracking',
                value: _location,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _location = v);
                },
              ),
              const SizedBox(height: 10),
              _PermissionTile(
                icon: Icons.notifications,
                title: 'Stay Updated',
                sub: 'Real-time order status',
                value: _notifications,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _notifications = v);
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onContinue?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Continue'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => (widget.onSkip ?? widget.onContinue)?.call(),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon, required this.title, required this.sub,
    required this.value, required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                Text(sub, style: text.labelMedium),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
