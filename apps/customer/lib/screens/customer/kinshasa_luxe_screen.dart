import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `kinshasa_luxe_delivery` — premium tier showcase / value prop screen.
///
/// Subscription / "Luxe" tier explainer: hero, perks grid, two CTAs.
class KinshasaLuxeScreen extends StatelessWidget {
  const KinshasaLuxeScreen({super.key});

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
            expandedHeight: 280,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: BackButton(color: scheme.onSurface),
            ),
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1400&q=85',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0xEEFCF9F8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Text('TASTYLIFE LUXE',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onPrimary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    const SizedBox(height: 12),
                    Text('Dining like a regular,\neverywhere in Kinshasa.',
                        style: text.displaySmall?.copyWith(height: 1.05)),
                    const SizedBox(height: 10),
                    Text(
                      'Skip queues, unlock private chef tables, and ride with our '
                      'top drivers — for the price of two dinners a month.',
                      style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: TastySpacing.sectionGap),
                    Text('Perks', style: text.titleMedium),
                    const SizedBox(height: TastySpacing.stackMd),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate.fixed(const [
                _Perk(icon: Icons.bolt, title: 'Priority queue', sub: 'You\'re always first in line'),
                _Perk(icon: Icons.diamond, title: 'Chef\'s table', sub: 'Private menus and tastings'),
                _Perk(icon: Icons.delivery_dining, title: 'Top-rated drivers', sub: '4.9+ rated only'),
                _Perk(icon: Icons.local_offer, title: '−15% every order', sub: 'On every restaurant'),
                _Perk(icon: Icons.event_available, title: 'Pop-up events', sub: 'Invite-only nights'),
                _Perk(icon: Icons.headset_mic, title: '24/7 concierge', sub: 'Direct line to ops'),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(TastySpacing.gutterCard),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.primaryContainer],
                      ),
                      borderRadius: TastyRadii.xxlRadius,
                      boxShadow: TastyShadows.glow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Try 30 days free',
                                  style: text.titleMedium?.copyWith(color: Colors.white)),
                              Text('Then 32 000 FC / month · cancel anytime',
                                  style: text.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: scheme.primary,
                          ),
                          child: const Text('Start'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(onPressed: () {}, child: const Text('See full plan details')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const Spacer(),
          Text(title, style: text.titleSmall),
          const SizedBox(height: 4),
          Text(sub, style: text.bodySmall),
        ],
      ),
    );
  }
}
