import 'dart:ui';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/restaurant.dart';
import '../../state/cart_controller.dart';
import '../../widgets/tasty_location_header.dart';
import 'category_restaurants_screen.dart';
import 'explore_categories_screen.dart';
import 'explore_tastylife_screen.dart';
import 'find_my_craving_screen.dart';
import 'kinshasa_luxe_screen.dart';
import 'live_order_tracking_screen.dart';
import 'loyalty_rewards_screen.dart';
import 'restaurant_detail_screen.dart';
import 'smart_search_screen.dart';

/// `immersive_home_experience` from the Stitch reference.
///
/// Cinematic hero (photographic background + greeting + floating search +
/// live-ETA pill) → story-style promos → trending restaurants rail.
///
/// Set [hideBottomNav] when hosting inside a parent that supplies its own
/// nav (e.g. [HomeShell]).
class ImmersiveHomeScreen extends StatelessWidget {
  const ImmersiveHomeScreen({super.key, this.hideBottomNav = false});
  final bool hideBottomNav;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: TastyLocationHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
            SliverToBoxAdapter(
              child: _CinematicHero(
                onEtaTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveOrderTrackingScreen()),
                ),
                onSearchTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SmartSearchScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
            const SliverToBoxAdapter(child: _HomeFilterChips()),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _LoyaltyProgressCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoyaltyRewardsScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _FindMyCravingCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FindMyCravingScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _PromoStories(
                onCategoryTap: (label, tags) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryRestaurantsScreen(
                      categoryLabel: label,
                      tags: tags,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Trending in Kinshasa',
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExploreCategoriesScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
            const SliverToBoxAdapter(child: _TrendingRail()),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            // Editorial entry — TastyLife magazine
            SliverToBoxAdapter(
              child: _EditorialBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExploreTastyLifeScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Order Again',
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExploreCategoriesScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
            const SliverToBoxAdapter(child: _OrderAgainRow()),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'All Restaurants',
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExploreCategoriesScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
            const SliverToBoxAdapter(child: _AllRestaurantsList()),
            const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
            // Luxe upsell banner
            SliverToBoxAdapter(
              child: _LuxeBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KinshasaLuxeScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      bottomNavigationBar: hideBottomNav ? null : const _HomeBottomNav(),
    );
  }
}

class _CinematicHero extends StatelessWidget {
  const _CinematicHero({this.onEtaTap, this.onSearchTap});
  final VoidCallback? onEtaTap;
  final VoidCallback? onSearchTap;
  static const _bg =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBmzZCpCvxYbqwAACkJBHfHvdbmg4NoXiowAgxLUfaTLqrAJyo9L5mEY-x6Jf3JVoEVOD97kFBwtiZWBc5HkzXoHJz_VBj2RE3rjiJ6gehNFkCzRbUllmQ8RV69PvZLARYUPYMdJuASxphvgNzYeV2tC0pn6ZX5N0b7kUN3vkPW9IF5OTZ-jh6SZUX57VMHL9sC3DcvPkPvrlhi2evxkFDLIH1EyFThPBtufyY6tApEITw1R1ZAEexlwmEEzlNb_tjylTEOv0TiyxI';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: ClipRRect(
        borderRadius: TastyRadii.xlRadius,
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(_bg, fit: BoxFit.cover, errorBuilder: _imageFallback),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x33000000), Color(0xB3000000)],
                  ),
                ),
              ),
              // Live ETA pill, top-right
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onEtaTap,
                  child: _GlassPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: TastyRadii.fullRadius,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pedal_bike, color: scheme.primaryContainer, size: 18),
                        const SizedBox(width: 6),
                        Text('15 min',
                            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Greeting + search at bottom
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Good Evening, Merveille',
                        style: text.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      'Discover the finest culinary experiences in Kinshasa tonight.',
                      style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    GestureDetector(
                      onTap: onSearchTap,
                      child: _GlassPanel(
                        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                        borderRadius: TastyRadii.fullRadius,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(Icons.search, color: scheme.onSurfaceVariant, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search for sushi, burgers, …',
                                style: text.bodyMedium?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.65),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                                boxShadow: TastyShadows.glow,
                              ),
                              child: Icon(Icons.tune, color: scheme.onPrimaryContainer, size: 18),
                            ),
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
      ),
    );
  }
}

class _PromoStories extends StatelessWidget {
  const _PromoStories({required this.onCategoryTap});

  /// Fired with (label, tags) when a category circle is tapped.
  final void Function(String label, List<String> tags) onCategoryTap;

  /// Each circle is a discoverable cuisine / mood. The `tags` list is what
  /// CategoryRestaurantsScreen filters against. "50% Off" routes the user
  /// to budget restaurants by matching the `cheap`/`comfort` tags.
  static const _items = <_PromoItem>[
    _PromoItem('50% Off', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&q=80', true, tags: ['cheap', 'comfort']),
    _PromoItem('New Sushi', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&q=80', false, tags: ['sushi', 'asian']),
    _PromoItem('Healthy', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=200&q=80', true, tags: ['healthy']),
    _PromoItem('Desserts', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=200&q=80', false, tags: ['dessert', 'cafe']),
    _PromoItem('Late Night', 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=200&q=80', true, tags: ['comfort', 'burger', 'pizza']),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
        itemBuilder: (_, i) {
          final p = _items[i];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onCategoryTap(p.label, p.tags);
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: p.featured
                        ? LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [scheme.primaryContainer, scheme.primary],
                          )
                        : null,
                    color: p.featured ? null : scheme.outlineVariant,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: scheme.surfaceContainerLowest, shape: BoxShape.circle),
                    child: ClipOval(
                      child: SizedBox(
                        width: 72, height: 72,
                        child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: _imageFallback),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TastySpacing.stackSm),
                Text(p.label, style: text.labelMedium),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: TastySpacing.gutterCard),
        itemCount: _items.length,
      ),
    );
  }
}

class _PromoItem {
  const _PromoItem(this.label, this.image, this.featured, {required this.tags});
  final String label;
  final String image;
  final bool featured;
  final List<String> tags;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Row(
        children: [
          Expanded(child: Text(title, style: text.titleMedium)),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(children: [
              Text('See All', style: text.labelMedium?.copyWith(color: scheme.primary)),
              Icon(Icons.chevron_right, color: scheme.primary, size: 18),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Toters-style quick filters under the search. Tapping one jumps into the
/// browsable category/explore screen (in-place filtering would need the home
/// to be stateful; navigation keeps it a clean StatelessWidget).
class _HomeFilterChips extends StatelessWidget {
  const _HomeFilterChips();
  static const _filters = ['Offers', 'Free Delivery', 'Top Rated', 'New'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ActionChip(
          label: Text(_filters[i]),
          labelStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
          backgroundColor: scheme.surfaceContainerLow,
          side: BorderSide(color: scheme.outlineVariant),
          shape: const StadiumBorder(),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExploreCategoriesScreen()),
            );
          },
        ),
      ),
    );
  }
}

/// Gold-tier loyalty progress, reading live points from [CartController].
class _LoyaltyProgressCard extends StatelessWidget {
  const _LoyaltyProgressCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final pts = cart.loyaltyPoints;
        final progress =
            (pts / CartController.loyaltyTierTarget).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
          child: Material(
            color: Colors.transparent,
            borderRadius: TastyRadii.xlRadius,
            child: InkWell(
              borderRadius: TastyRadii.xlRadius,
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: TastyRadii.xlRadius,
                  boxShadow: TastyShadows.ambient,
                  border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium,
                            color: scheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Gold member', style: text.titleSmall),
                        const Spacer(),
                        Text('$pts pts',
                            style: text.titleSmall
                                ?.copyWith(color: scheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: TastyRadii.fullRadius,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation(scheme.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${cart.pointsToNextTier} points to Platinum',
                        style: text.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full vertical list of every restaurant in the catalogue (Toters' "All
/// Stores"). Each row opens the real [RestaurantDetailScreen] for that store.
class _AllRestaurantsList extends StatelessWidget {
  const _AllRestaurantsList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Column(
        children: [
          for (final r in RestaurantCatalog.all) ...[
            _RestaurantRow(restaurant: r),
            const SizedBox(height: TastySpacing.gutterCard),
          ],
        ],
      ),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  const _RestaurantRow({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: TastyRadii.lgRadius,
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.network(restaurant.heroImage,
                      fit: BoxFit.cover, errorBuilder: _imageFallback),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text('${restaurant.cuisine} · ${restaurant.district}',
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: scheme.primary),
                        const SizedBox(width: 2),
                        Text('${restaurant.rating}', style: text.labelMedium),
                        const SizedBox(width: 10),
                        Icon(Icons.pedal_bike,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(restaurant.etaRange, style: text.labelMedium),
                        const SizedBox(width: 10),
                        Text(restaurant.priceLevel,
                            style: text.labelMedium
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
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

class _TrendingRail extends StatelessWidget {
  const _TrendingRail();
  static const _items = <_RestaurantCard>[
    _RestaurantCard(
      name: 'Le Grill Premium',
      cuisine: 'Steakhouse · Gombe',
      eta: '20–30 min',
      price: '\$\$\$',
      rating: 4.8,
      image:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=900&q=80',
    ),
    _RestaurantCard(
      name: 'Maison Kinshasa',
      cuisine: 'Congolese · Lingwala',
      eta: '15–25 min',
      price: '\$\$',
      rating: 4.6,
      image:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&q=80',
    ),
    _RestaurantCard(
      name: 'Sushi Lounge',
      cuisine: 'Japanese · Limete',
      eta: '25–35 min',
      price: '\$\$\$',
      rating: 4.7,
      image:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=900&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 276,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
        itemBuilder: (_, i) => SizedBox(
          width: 260,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RestaurantDetailScreen()),
            ),
            child: _items[i],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: TastySpacing.gutterCard),
        itemCount: _items.length,
      ),
    );
  }
}

/// HungerStation-style "Find My Craving" entry. Tappable card with a
/// gradient hook and the magic-wand emoji. Lives between the hero and
/// the promo stories so it's impossible to miss.
class _FindMyCravingCard extends StatelessWidget {
  const _FindMyCravingCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Material(
        borderRadius: TastyRadii.xlRadius,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TastyRadii.xlRadius,
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.glow,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🪄', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find My Craving',
                        style: text.titleMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI picks 5 dishes that match your mood right now.',
                        style: text.bodySmall?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.name,
    required this.cuisine,
    required this.eta,
    required this.price,
    required this.rating,
    required this.image,
  });
  final String name;
  final String cuisine;
  final String eta;
  final String price;
  final double rating;
  final String image;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xl)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(image, fit: BoxFit.cover, errorBuilder: _imageFallback),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: CartController.instance,
                      builder: (context, _) {
                        final fav = CartController.instance.isFavorite(name);
                        return Material(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              CartController.instance.toggleFavorite(name);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(fav
                                    ? 'Removed $name from favourites'
                                    : 'Added $name to favourites'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                color: fav ? TastyColors.brandOrange : Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(cuisine, style: text.bodySmall),
                const SizedBox(height: TastySpacing.stackSm),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text('$rating', style: text.labelMedium),
                    const SizedBox(width: TastySpacing.stackSm),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: scheme.outline, shape: BoxShape.circle)),
                    const SizedBox(width: TastySpacing.stackSm),
                    Text(eta, style: text.labelMedium),
                    const Spacer(),
                    Text(price, style: text.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderAgainRow extends StatelessWidget {
  const _OrderAgainRow();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Container(
        padding: const EdgeInsets.all(TastySpacing.stackMd),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: TastyRadii.xlRadius,
          boxShadow: TastyShadows.ambient,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: TastyRadii.mdRadius,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.network(
                  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: _imageFallback,
                ),
              ),
            ),
            const SizedBox(width: TastySpacing.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Poulet Moambe', style: text.titleSmall),
                  Text('From Maison Kinshasa', style: text.bodySmall),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RestaurantDetailScreen()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
              child: const Text('Reorder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      destinations: const [
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding = EdgeInsets.zero, this.borderRadius = TastyRadii.fullRadius});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget _imageFallback(BuildContext _, Object __, StackTrace? ___) => Container(
      color: const Color(0xFFE5E2E1),
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF877462)),
    );

class _EditorialBanner extends StatelessWidget {
  const _EditorialBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        child: InkWell(
          borderRadius: TastyRadii.xlRadius,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(TastyRadii.xl)),
                  child: SizedBox(
                    width: 110, height: 110,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: _imageFallback,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(TastySpacing.stackMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TASTYLIFE · THE ISSUE',
                            style: text.labelSmall?.copyWith(
                              color: scheme.primary,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 4),
                        Text('Eat Like a Local',
                            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Weekly editorial guide to Kinshasa\'s living kitchens.',
                            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxeBanner extends StatelessWidget {
  const _LuxeBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Material(
        color: TastyColors.brandInk,
        borderRadius: TastyRadii.xlRadius,
        child: InkWell(
          borderRadius: TastyRadii.xlRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: TastyColors.brandOrange,
                    shape: BoxShape.circle,
                    boxShadow: TastyShadows.glow,
                  ),
                  child: const Icon(Icons.diamond, color: TastyColors.brandInk),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TASTYLIFE LUXE',
                          style: text.labelSmall?.copyWith(
                            color: TastyColors.brandOrange,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 2),
                      Text('Try 30 days free →',
                          style: text.titleMedium?.copyWith(color: Colors.white)),
                      Text('Priority queue, chef\'s tables, 24/7 concierge.',
                          style: text.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.75)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
