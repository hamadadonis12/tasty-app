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
                          _StatPill(
                            icon: Icons.delivery_dining,
                            label:
                                'Free delivery over \$${_r.freeDeliveryMinimum.toStringAsFixed(0)}',
                            sub: '',
                            highlight: true,
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

/// Menu tab: a sticky category selector (horizontal chips + a "≡" button that
/// opens the full vertical category list) above the grouped, scrollable menu.
/// The active chip tracks the scroll position, and tapping any category jumps
/// to that section.
class _MenuList extends StatefulWidget {
  const _MenuList({required this.restaurant});
  final Restaurant restaurant;
  @override
  State<_MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<_MenuList> {
  final ScrollController _scroll = ScrollController();
  final List<String> _order = <String>[];
  final Map<String, List<MenuItem>> _byCategory = <String, List<MenuItem>>{};
  late final List<GlobalKey> _sectionKeys;

  int _active = 0;
  bool _programmaticScroll = false;

  /// Distance from the list's top below which a section header counts as the
  /// "current" section (roughly the category-bar height).
  static const double _activeThreshold = 64;

  @override
  void initState() {
    super.initState();
    // Group items into sections, preserving first-seen category order.
    for (final item in widget.restaurant.menu) {
      final cat = item.category.isEmpty ? 'Menu' : item.category;
      (_byCategory[cat] ??= <MenuItem>[]).add(item);
      if (!_order.contains(cat)) _order.add(cat);
    }
    _sectionKeys = List.generate(_order.length, (_) => GlobalKey());
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_programmaticScroll) return;
    final listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;
    int current = _active;
    double best = double.negativeInfinity;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero, ancestor: listBox).dy;
      // Pick the section header closest to (but not past) the top line.
      if (dy <= _activeThreshold && dy > best) {
        best = dy;
        current = i;
      }
    }
    if (current != _active) setState(() => _active = current);
  }

  Future<void> _jumpTo(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _active = index);
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    _programmaticScroll = true;
    await Scrollable.ensureVisible(
      ctx,
      duration: TastyMotion.durationMd,
      curve: TastyMotion.emphasizedDecelerate,
    );
    if (mounted) _programmaticScroll = false;
  }

  void _openCategorySheet() {
    HapticFeedback.lightImpact();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: scheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TastySpacing.marginPage,
            TastySpacing.stackMd,
            TastySpacing.marginPage,
            TastySpacing.stackMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: TastyRadii.fullRadius,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Categories', style: text.titleLarge),
              const SizedBox(height: TastySpacing.stackSm),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _order.length,
                  itemBuilder: (_, i) {
                    final selected = i == _active;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_order[i],
                          style: text.bodyLarge?.copyWith(
                            color: selected ? scheme.primary : scheme.onSurface,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          )),
                      trailing: Text('${_byCategory[_order[i]]!.length}',
                          style: text.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        _jumpTo(i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (_order.length > 1)
          _CategoryBar(
            categories: _order,
            activeIndex: _active,
            onSelect: _jumpTo,
            onMenuTap: _openCategorySheet,
          ),
        Expanded(
          child: ListView(
            controller: _scroll,
            // Clear the lifted bag pill (which now sits above the nav inset).
            padding: EdgeInsets.fromLTRB(
              TastySpacing.marginPage,
              TastySpacing.stackLg,
              TastySpacing.marginPage,
              150 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            children: [
              for (var s = 0; s < _order.length; s++) ...[
                if (s > 0) const SizedBox(height: TastySpacing.sectionGap),
                Padding(
                  key: _sectionKeys[s],
                  padding: const EdgeInsets.only(bottom: TastySpacing.stackMd),
                  child: Row(
                    children: [
                      Text(_order[s], style: text.titleMedium),
                      const SizedBox(width: 8),
                      Text('${_byCategory[_order[s]]!.length}',
                          style: text.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                for (final item in _byCategory[_order[s]]!) ...[
                  _MenuItemTile(item: item, restaurant: widget.restaurant),
                  const SizedBox(height: TastySpacing.gutterCard),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal, scrollable category selector with a leading "≡" button that
/// opens the full vertical category list. Mirrors the Toters / Uber-Eats menu
/// nav. The active chip auto-scrolls into view as the menu scrolls.
class _CategoryBar extends StatefulWidget {
  const _CategoryBar({
    required this.categories,
    required this.activeIndex,
    required this.onSelect,
    required this.onMenuTap,
  });
  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onMenuTap;

  @override
  State<_CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<_CategoryBar> {
  final ScrollController _hScroll = ScrollController();
  late List<GlobalKey> _chipKeys =
      List.generate(widget.categories.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(_CategoryBar old) {
    super.didUpdateWidget(old);
    if (old.categories.length != widget.categories.length) {
      _chipKeys =
          List.generate(widget.categories.length, (_) => GlobalKey());
    }
    if (old.activeIndex != widget.activeIndex) {
      // Keep the active chip on-screen as the menu scrolls.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _chipKeys[widget.activeIndex].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: TastyMotion.durationSm,
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  color: scheme.onSurface,
                  tooltip: 'All categories',
                  onPressed: widget.onMenuTap,
                ),
                Expanded(
                  child: ListView.separated(
                    controller: _hScroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: TastySpacing.marginPage),
                    itemCount: widget.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final selected = i == widget.activeIndex;
                      return Center(
                        child: GestureDetector(
                          key: _chipKeys[i],
                          onTap: () => widget.onSelect(i),
                          child: AnimatedContainer(
                            duration: TastyMotion.durationSm,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? scheme.primary
                                  : scheme.surfaceContainerLow,
                              borderRadius: TastyRadii.fullRadius,
                              border: Border.all(
                                color: selected
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                              ),
                            ),
                            child: Text(
                              widget.categories[i],
                              style: text.labelLarge?.copyWith(
                                color: selected
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
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
          Divider(height: 1, thickness: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ],
      ),
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
  const _StatPill({
    required this.icon,
    required this.label,
    required this.sub,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final String sub;

  /// When true the pill uses the success (green) palette — used for the
  /// "free delivery" perk so it reads as a benefit, not a neutral stat.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bg = highlight
        ? TastyColors.successContainer
        : scheme.surfaceContainerLow;
    final fg = highlight ? TastyColors.onSuccessContainer : scheme.primary;
    final labelColor =
        highlight ? TastyColors.onSuccessContainer : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TastyRadii.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: text.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: labelColor)),
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
