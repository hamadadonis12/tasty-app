import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `driver_command_center` — driver's map-first home: city map with hot
/// zones, online toggle, stat strip, current shift status, FAB action.
class DriverCommandCenterScreen extends StatelessWidget {
  const DriverCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TastySpacing.marginPage,
                TastySpacing.stackSm,
                TastySpacing.marginPage,
                TastySpacing.stackMd,
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                  Text('KINSHASA EATS',
                      style: text.titleMedium?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.4,
                      )),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
                    ),
                  ),
                ],
              ),
            ),
            // Online toggle pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: TastyRadii.fullRadius,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text('Offline', style: text.titleSmall),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                        ),
                        child: const Text('Online'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TastySpacing.stackMd),
            // Map placeholder
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.1, -0.1),
                          radius: 1.2,
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.3),
                            scheme.surfaceContainerLow,
                          ],
                        ),
                        borderRadius: TastyRadii.xlRadius,
                      ),
                      child: Stack(
                        children: [
                          // Hot zone dots
                          Positioned(top: 80, left: 60, child: _Hotspot(scheme: scheme, label: 'B')),
                          Positioned(top: 160, left: 110, child: _Hotspot(scheme: scheme, label: 'K', highlight: true)),
                          Positioned(top: 220, left: 80, child: _Hotspot(scheme: scheme, label: 'M')),
                          Positioned(top: 100, right: 80, child: _Hotspot(scheme: scheme, label: 'L')),
                        ],
                      ),
                    ),
                  ),
                  // Stats card
                  Positioned(
                    left: TastySpacing.marginPage + 12,
                    right: TastySpacing.marginPage + 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: TastyRadii.xlRadius,
                        boxShadow: TastyShadows.ambient,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _Stat(label: 'Today', value: '14.5K', sub: 'FC', primary: scheme.primary)),
                          Container(width: 1, height: 36, color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          Expanded(child: _Stat(label: 'Orders', value: '12', sub: 'High Demand', primary: scheme.primary)),
                          Container(width: 1, height: 36, color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          Expanded(child: _Stat(label: 'Rating', value: '4.9', sub: '★', primary: scheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        onPressed: () {},
        child: const Icon(Icons.flash_on),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (_) {},
      ),
    );
  }
}

class _Hotspot extends StatelessWidget {
  const _Hotspot({required this.scheme, required this.label, this.highlight = false});
  final ColorScheme scheme;
  final String label;
  final bool highlight;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: highlight ? scheme.primary : scheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: highlight ? TastyShadows.glow : null,
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: TextStyle(
            color: highlight ? scheme.onPrimary : scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          )),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.sub, required this.primary});
  final String label;
  final String value;
  final String sub;
  final Color primary;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(label, style: text.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: text.titleMedium?.copyWith(color: primary)),
        Text(sub, style: text.labelSmall),
      ],
    );
  }
}
