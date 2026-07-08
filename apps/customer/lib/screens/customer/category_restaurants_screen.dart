import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/restaurant.dart';
import '../../state/cart_controller.dart';
import 'restaurant_detail_screen.dart';

/// Lightweight "all restaurants in category X" screen. Used by the home
/// category circles so a customer who taps "Sushi" lands on a real list
/// of sushi spots instead of the coupon wallet.
///
/// [categoryLabel] is the human-friendly title shown in the app bar
/// ("Healthy", "Late Night"). [tags] is the list of cuisine / mood tags
/// any of which is enough to match a restaurant (case-insensitive).
class CategoryRestaurantsScreen extends StatelessWidget {
  const CategoryRestaurantsScreen({
    super.key,
    required this.categoryLabel,
    required this.tags,
  });

  final String categoryLabel;
  final List<String> tags;

  List<Restaurant> _matches() {
    final lowered = tags.map((t) => t.toLowerCase()).toList();
    return RestaurantCatalog.all.where((r) {
      final hay = '${r.cuisine} ${r.tags.join(' ')} ${r.name}'.toLowerCase();
      return lowered.any(hay.contains);
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final matches = _matches();
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(categoryLabel),
        centerTitle: true,
      ),
      body: matches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.restaurant_outlined,
                          size: 40, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    Text('No restaurants matched "$categoryLabel"',
                        textAlign: TextAlign.center, style: text.titleMedium),
                    const SizedBox(height: 6),
                    Text('Try a different category from the home screen.',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              itemCount: matches.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: TastySpacing.stackMd),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: TastySpacing.stackSm),
                    child: Text(
                      '${matches.length} restaurants serve $categoryLabel near you',
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  );
                }
                return _RestaurantTile(restaurant: matches[i - 1]);
              },
            ),
    );
  }
}

class _RestaurantTile extends StatelessWidget {
  const _RestaurantTile({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: TastyRadii.lgRadius,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(restaurant.heroImage, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: ListenableBuilder(
                          listenable: CartController.instance,
                          builder: (ctx, _) {
                            final fav = CartController.instance.isFavorite(restaurant.name);
                            return Material(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  CartController.instance.toggleFavorite(restaurant.name);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Icon(
                                    fav ? Icons.favorite : Icons.favorite_border,
                                    color: fav ? TastyColors.brandOrange : Colors.white,
                                    size: 14,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text('${restaurant.cuisine} · ${restaurant.district}',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text('${restaurant.rating}', style: text.labelMedium),
                        const SizedBox(width: 10),
                        Container(
                          width: 3,
                          height: 3,
                          decoration:
                              BoxDecoration(color: scheme.outline, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(restaurant.etaRange, style: text.labelMedium),
                        const SizedBox(width: 10),
                        Text(restaurant.priceLevel,
                            style: text.labelMedium?.copyWith(
                                color: scheme.primary, fontWeight: FontWeight.w700)),
                      ],
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
