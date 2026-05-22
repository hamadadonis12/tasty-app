import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `delivery_address_setup` — map background + bottom sheet with search,
/// Current Location, Saved Places, Confirm CTA.
class DeliveryAddressSetupScreen extends StatelessWidget {
  const DeliveryAddressSetupScreen({super.key, this.onConfirm});
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Map area (image placeholder)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.surfaceContainer,
                      scheme.primaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Centered pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: TastyShadows.glow,
                    ),
                    child: Icon(Icons.location_on, color: scheme.onPrimary, size: 22),
                  ),
                  Container(width: 2, height: 14, color: scheme.primary),
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: scheme.primary, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.4), blurRadius: 12)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white,
                    borderRadius: TastyRadii.fullRadius,
                    child: InkWell(
                      borderRadius: TastyRadii.fullRadius,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onConfirm?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Skip', style: text.labelLarge),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                boxShadow: TastyShadows.sheet,
              ),
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: TastyRadii.fullRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    Text('Set Delivery Address',
                        textAlign: TextAlign.center, style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Move the map or search for a specific landmark.',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: scheme.primary),
                        hintText: 'Search for your street or landmark',
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    _AddressOption(
                      icon: Icons.my_location,
                      title: 'Current Location',
                      sub: 'Using GPS coordinates',
                      onTap: () => HapticFeedback.selectionClick(),
                    ),
                    const SizedBox(height: 8),
                    _AddressOption(
                      icon: Icons.bookmark,
                      title: 'Saved Places',
                      sub: 'Home, Work, and favorites',
                      onTap: () => HapticFeedback.selectionClick(),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onConfirm?.call();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirm Location'),
                    ),
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

class _AddressOption extends StatelessWidget {
  const _AddressOption({required this.icon, required this.title, required this.sub, required this.onTap});
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: scheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(title, style: text.titleSmall), Text(sub, style: text.labelMedium)],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
