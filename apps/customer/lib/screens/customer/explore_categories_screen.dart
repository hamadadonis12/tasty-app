import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/restaurant.dart';
import 'restaurant_detail_screen.dart';
import 'smart_search_screen.dart';

/// `explore_categories` from the Stitch reference.
///
/// Grid of cuisine categories: each tile is a glassy card with a hero
/// image, name, and a "trending" or "near you" sub-line.
class ExploreCategoriesScreen extends StatelessWidget {
  const ExploreCategoriesScreen({super.key});

  // Each tile carries the tag it filters the restaurant catalog with so a
  // category tap routes the customer to a restaurant that actually serves
  // that cuisine (issue #4 fix). The fallback restaurant is used only when
  // the catalog has no match for the tag.
  static const _items = <_CategoryItem>[
    _CategoryItem('Burgers', '142 places', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80', tag: 'burger', trending: true),
    _CategoryItem('Sushi', '38 places', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=80', tag: 'sushi'),
    _CategoryItem('Congolese', '96 places', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80', tag: 'congolese', trending: true),
    _CategoryItem('Pizza', '210 places', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80', tag: 'pizza'),
    _CategoryItem('Healthy', '64 places', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=600&q=80', tag: 'healthy'),
    _CategoryItem('Desserts', '88 places', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=80', tag: 'dessert'),
    _CategoryItem('Cafés', '120 places', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&q=80', tag: 'cafe'),
    _CategoryItem('Late Night', '54 places', 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=600&q=80', tag: 'comfort', trending: true),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Explore'),
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SmartSearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              TastySpacing.marginPage,
              TastySpacing.stackSm,
              TastySpacing.marginPage,
              TastySpacing.stackMd,
            ),
            sliver: SliverToBoxAdapter(
              child: Text('Browse 41 cuisines from Kinshasa & Brazzaville',
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: TastySpacing.gutterCard,
                crossAxisSpacing: TastySpacing.gutterCard,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _items[i],
                childCount: _items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem(this.name, this.subtitle, this.image,
      {required this.tag, this.trending = false});
  final String name;
  final String subtitle;
  final String image;
  final String tag;
  final bool trending;

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
          HapticFeedback.selectionClick();
          // Filter the catalog by tag; if there's no match, fall back to
          // the first restaurant rather than always Maison Kinshasa.
          final matches = RestaurantCatalog.forTag(tag);
          final target = matches.isEmpty ? RestaurantCatalog.all.first : matches.first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: target),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: TastyRadii.xlRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
          Image.network(image, fit: BoxFit.cover, errorBuilder: _imageFallback),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
          if (trending)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.9),
                  borderRadius: TastyRadii.fullRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: scheme.onPrimaryContainer, size: 14),
                    const SizedBox(width: 4),
                    Text('Trending',
                        style: text.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleMedium?.copyWith(color: Colors.white)),
                Text(subtitle,
                    style: text.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
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

Widget _imageFallback(BuildContext _, Object __, StackTrace? ___) => Container(
      color: const Color(0xFFE5E2E1),
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF877462)),
    );
