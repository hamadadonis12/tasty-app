import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `project_overview_showcase` — the executive pitch screen.
///
/// Cinematic hero, "TastyLife" headline, four-platform Bento grid
/// (Customer / Driver / Merchant / Admin), CTA "Explore The App".
class ProjectOverviewScreen extends StatelessWidget {
  const ProjectOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
            title: Text('TastyLife',
                style: text.titleLarge?.copyWith(color: scheme.primary)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 11,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1400&q=85',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, scheme.surface],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24, right: 24, bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer.withValues(alpha: 0.25),
                                  borderRadius: TastyRadii.fullRadius,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.rocket_launch, size: 14, color: scheme.onPrimaryContainer),
                                    const SizedBox(width: 6),
                                    Text('Executive Overview',
                                        style: text.labelSmall?.copyWith(
                                            color: scheme.onPrimaryContainer)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('TastyLife:',
                                  style: text.displayMedium?.copyWith(color: scheme.onSurface, height: 1.0)),
                              Text('Next-Gen African',
                                  style: text.displayMedium?.copyWith(color: scheme.onSurface, height: 1.0)),
                              Text('Delivery Ecosystem',
                                  style: text.displayMedium?.copyWith(color: scheme.primary, height: 1.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TastySpacing.gutterCard),
                  Text(
                    'Bridging the gap between surgical logistics efficiency and the '
                    'vibrant hospitality of modern African urban centers. A unified '
                    'platform connecting diners, drivers, and restaurants through a '
                    'frictionless, Luxe-Functional experience.',
                    style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: TastySpacing.sectionGap),
                  Row(
                    children: [
                      Text('The Core Platforms', style: text.titleLarge),
                      const Spacer(),
                      Text('ECOSYSTEM ARCHITECTURE',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1.6,
                          )),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: const [
                      _Platform(icon: Icons.restaurant_menu, title: 'Customer App',
                          sub: 'Immersive discovery, frictionless ordering, real-time tracking, personalized recommendations.'),
                      _Platform(icon: Icons.pedal_bike, title: 'Driver App',
                          sub: 'High-utility interface for surgical efficiency. Optimized routing, clear earnings, one-tap states.'),
                      _Platform(icon: Icons.storefront, title: 'Merchant Portal',
                          sub: 'Streamlined kitchen ops. Live order queues, menu management, financials on a tablet-first layout.'),
                      _Platform(icon: Icons.dashboard, title: 'Admin Dashboard',
                          sub: 'The command center. Fleet tracking, revenue analytics, system-wide controls in elegant data viz.'),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.sectionGap),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Explore The App'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform({required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(TastySpacing.gutterCard),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const Spacer(),
          Text(title, style: text.titleMedium),
          const SizedBox(height: 6),
          Text(sub, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
