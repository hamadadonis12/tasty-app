import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../state/cart_controller.dart';
import 'cart_screen.dart';
import 'customize_order_screen.dart';

/// `restaurant_detail` — parallax hero → sticky tab bar (Menu / Reviews /
/// Info) → menu list / reviews list / info panel → sticky bottom bag pill.
///
/// Driven by a passed-in [Restaurant] so every search / category / home
/// tap shows the actual restaurant the customer picked.
class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, this.restaurant});
  final Restaurant? restaurant;
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late final Restaurant _r = widget.restaurant ?? RestaurantCatalog.byId('maison-kinshasa');
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    // Re-bind the cart to this restaurant if it's empty (avoids cross-restaurant
    // cart corruption). If the cart already belongs to another restaurant,
    // the customize screen will surface that conflict when adding.
    if (CartController.instance.items.isEmpty) {
      CartController.instance.setRestaurant(id: _r.id, name: _r.name);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Fixed 40px circular glass button for the hero app bar — identical to the
  /// item detail screen so back/favorite look consistent and never balloon as
  /// the SliverAppBar collapses.
  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                leadingWidth: 56,
                leading: _circleButton(Icons.arrow_back, () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                }),
                actions: [
                  _circleButton(Icons.favorite_border, HapticFeedback.lightImpact),
                  const SizedBox(width: TastySpacing.stackMd),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _r.heroImage, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCCFCF9F8)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: TastySpacing.marginPage,
                    vertical: TastySpacing.stackMd,
                  ),
                  padding: const EdgeInsets.all(TastySpacing.gutterCard),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: TastyRadii.xlRadius,
                    boxShadow: TastyShadows.ambient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_r.name, style: text.titleLarge),
                      const SizedBox(height: 4),
                      Text('${_r.cuisine} · ${_r.district} · ${_r.priceLevel}',
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: TastySpacing.stackMd),
                      // Wrap (not Row) so the pills flow to a second line on
                      // narrow screens instead of overflowing on the right.
                      Wrap(
                        spacing: TastySpacing.stackSm,
                        runSpacing: TastySpacing.stackSm,
                        children: [
                          _StatPill(
                            icon: Icons.star_rounded,
                            label: '${_r.rating}',
                            sub: '(${_r.reviewCount})',
                          ),
                          _StatPill(
                            icon: Icons.pedal_bike,
                            label: _r.etaRange,
                            sub: '',
                          ),
                          _StatPill(
                            icon: Icons.account_balance_wallet_outlined,
                            label: '\$${_r.deliveryFee.toStringAsFixed(2)} fee',
                            sub: '',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  child: Container(
                    color: scheme.surface,
                    child: TabBar(
                      controller: _tabs,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Menu'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'Info'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _MenuList(restaurant: _r),
                _ReviewsList(restaurant: _r),
                _InfoPanel(restaurant: _r),
              ],
            ),
          ),
          // Sticky bottom "View Cart" pill — driven by CartController.
          Positioned(
            left: TastySpacing.marginPage,
            right: TastySpacing.marginPage,
            // Lift above the device's bottom nav inset so the pill isn't
            // hidden under the system navigation bar.
            bottom: 24 + MediaQuery.viewPaddingOf(context).bottom,
            child: ListenableBuilder(
              listenable: CartController.instance,
              builder: (_, __) {
                final cart = CartController.instance;
                final empty = cart.itemCount == 0;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: TastyRadii.fullRadius,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: empty ? scheme.surfaceContainerHigh : scheme.primary,
                        borderRadius: TastyRadii.fullRadius,
                        boxShadow: empty ? null : TastyShadows.glow,
                      ),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: TastyMotion.durationSm,
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: Container(
                              key: ValueKey(cart.itemCount),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: empty
                                    ? scheme.surfaceContainerLow
                                    : Colors.white.withValues(alpha: 0.25),
                                borderRadius: TastyRadii.fullRadius,
                              ),
                              child: Text('${cart.itemCount}',
                                  style: text.labelLarge?.copyWith(
                                    color: empty ? scheme.onSurface : Colors.white,
                                  )),
                            ),
                          ),
                          const SizedBox(width: TastySpacing.stackMd),
                          Text(empty ? 'Your bag is empty' : 'View bag',
                              style: text.titleSmall?.copyWith(
                                color: empty ? scheme.onSurface : Colors.white,
                              )),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: TastyMotion.durationSm,
                            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                            child: Text(
                              '\$${cart.subtotal.toStringAsFixed(2)}',
                              key: ValueKey(cart.subtotal),
                              style: text.titleSmall?.copyWith(
                                color: empty ? scheme.onSurface : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.restaurant});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Group items into sections, preserving first-seen category order.
    final order = <String>[];
    final byCategory = <String, List<MenuItem>>{};
    for (final item in restaurant.menu) {
      final cat = item.category.isEmpty ? 'Menu' : item.category;
      (byCategory[cat] ??= <MenuItem>[]).add(item);
      if (!order.contains(cat)) order.add(cat);
    }

    return ListView(
      // Clear the lifted bag pill (which now sits above the nav inset).
      padding: EdgeInsets.fromLTRB(
        TastySpacing.marginPage,
        TastySpacing.stackLg,
        TastySpacing.marginPage,
        150 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        for (var s = 0; s < order.length; s++) ...[
          if (s > 0) const SizedBox(height: TastySpacing.sectionGap),
          Padding(
            padding: const EdgeInsets.only(bottom: TastySpacing.stackMd),
            child: Row(
              children: [
                Text(order[s], style: text.titleMedium),
                const SizedBox(width: 8),
                Text('${byCategory[order[s]]!.length}',
                    style: text.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          for (final item in byCategory[order[s]]!) ...[
            _MenuItemTile(item: item, restaurant: restaurant),
            const SizedBox(height: TastySpacing.gutterCard),
          ],
        ],
      ],
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({required this.restaurant});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reviews = const [
      ('Merveille K.', 5, 'Le poulet moambe est exceptionnel — livré chaud en 18 min!'),
      ('Paul-Henri', 4, 'Solid portions. Sauce was rich. Could use more spice.'),
      ('Aïcha M.', 5, 'My go-to for Friday family dinners. Liboke is always perfect.'),
      ('David R.', 5, 'Driver was professional and food arrived bien chaud.'),
      ('Sandrine T.', 4, 'Great food. Wish bissap came in a bigger bottle.'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TastySpacing.marginPage, TastySpacing.stackLg, TastySpacing.marginPage, 140,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(TastySpacing.gutterCard),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          child: Row(
            children: [
              Text('${restaurant.rating}',
                  style: text.displaySmall?.copyWith(color: scheme.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        final filled = i < restaurant.rating.round();
                        return Icon(
                          filled ? Icons.star_rounded : Icons.star_border_rounded,
                          color: scheme.primary, size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 2),
                    Text('${restaurant.reviewCount} reviews · last 30 days',
                        style: text.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TastySpacing.gutterCard),
        for (final r in reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(TastySpacing.stackMd),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: TastyRadii.lgRadius,
                boxShadow: TastyShadows.ambient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(r.$1, style: text.titleSmall),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < r.$2;
                          return Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: scheme.primary, size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.$3, style: text.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.restaurant});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TastySpacing.marginPage, TastySpacing.stackLg, TastySpacing.marginPage, 140,
      ),
      children: [
        _InfoTile(
          icon: Icons.location_on_outlined,
          title: 'Address',
          body: '${restaurant.district}, Kinshasa',
        ),
        _InfoTile(
          icon: Icons.access_time,
          title: 'Opening hours',
          body: 'Mon–Sun · 11:00 – 23:00\nLast order 22:30',
        ),
        _InfoTile(
          icon: Icons.call_outlined,
          title: 'Contact',
          body: '+243 89 *** **${restaurant.id.hashCode.abs() % 100}',
        ),
        _InfoTile(
          icon: Icons.local_dining,
          title: 'Cuisine',
          body: restaurant.cuisine,
        ),
        _InfoTile(
          icon: Icons.health_and_safety,
          title: 'Health & hygiene',
          body: 'Audited 12 days ago · Grade A',
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(TastySpacing.stackMd),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: TastyRadii.lgRadius,
          boxShadow: TastyShadows.ambient,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 2),
                  Text(body, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: TastyRadii.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (sub.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(sub, style: text.labelSmall),
          ]
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.child});
  final Widget child;
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item, required this.restaurant});
  final MenuItem item;
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
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomizeOrderScreen(
                item: item,
                restaurantName: restaurant.name,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          // Use IntrinsicHeight so the image clip lines up with the text
          // column without forcing a Row.stretch inside a Sliver (which
          // previously crashed at scroll time).
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(TastySpacing.stackMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.featured
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHigh,
                              borderRadius: TastyRadii.fullRadius,
                            ),
                            child: Text(item.badge!,
                                style: text.labelSmall?.copyWith(
                                  color: item.featured
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                )),
                          ),
                        if (item.badge != null) const SizedBox(height: 8),
                        Text(item.name, style: text.titleSmall),
                        const SizedBox(height: 4),
                        Text(item.description,
                            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: TastySpacing.stackMd),
                        Text('\$${item.price.toStringAsFixed(2)}',
                            style: text.titleSmall?.copyWith(
                              color: scheme.primary, fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(TastyRadii.xl)),
                      child: SizedBox(
                        width: 120,
                        height: 130,
                        child: Image.network(
                          item.image, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8, bottom: 8,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: TastyShadows.glow,
                        ),
                        child: Icon(Icons.add, color: scheme.onPrimaryContainer, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
