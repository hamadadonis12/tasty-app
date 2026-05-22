import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import 'restaurant_detail_screen.dart';

/// `smart_search_experience` — global search across dishes + restaurants.
///
/// Results derive from the real [RestaurantCatalog]. Tapping a restaurant
/// row opens that restaurant's detail. Tapping a dish row opens the dish's
/// restaurant detail (where the dish lives). Both pass the actual model
/// so no more "everything goes to Maison Kinshasa".
class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});
  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _query = _ctrl.text.trim()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_SearchHit> get _hits {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    final out = <_SearchHit>[];
    for (final r in RestaurantCatalog.all) {
      final hay = '${r.name} ${r.cuisine} ${r.district} ${r.tags.join(' ')}'.toLowerCase();
      if (hay.contains(q)) {
        out.add(_SearchHit.restaurant(r));
      }
      for (final m in r.menu) {
        if (m.name.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q)) {
          out.add(_SearchHit.dish(r, m));
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Sushi, burgers, Maison Kinshasa…',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: () {
                HapticFeedback.selectionClick();
                _ctrl.clear();
              },
            )
          else
            IconButton(icon: const Icon(Icons.mic_none), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: _query.isEmpty
          ? _IdleState(onChipTap: (q) {
              _ctrl.text = q;
              _ctrl.selection = TextSelection.collapsed(offset: q.length);
            })
          : _ResultsList(hits: _hits),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState({required this.onChipTap});
  final ValueChanged<String> onChipTap;
  static const _recents = ['Poulet Moambe', 'Sushi', 'Pizza', 'Burger', 'Bissap'];
  static const _moods = <(String, String)>[
    ('🌶️', 'Spicy'),
    ('🥗', 'Healthy'),
    ('🍔', 'Comfort'),
    ('💸', 'Cheap eats'),
    ('💍', 'Date night'),
    ('☕', 'Cafés'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(TastySpacing.marginPage),
      children: [
        Text('Recent', style: text.titleSmall),
        const SizedBox(height: TastySpacing.stackSm),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final r in _recents)
              ActionChip(
                label: Text(r),
                avatar: const Icon(Icons.history, size: 16),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onChipTap(r);
                },
              ),
          ],
        ),
        const SizedBox(height: TastySpacing.sectionGap),
        Text('Search by mood', style: text.titleSmall),
        const SizedBox(height: TastySpacing.stackMd),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2.6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final m in _moods)
              Material(
                color: scheme.surfaceContainerLow,
                borderRadius: TastyRadii.lgRadius,
                child: InkWell(
                  borderRadius: TastyRadii.lgRadius,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChipTap(m.$2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Text(m.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(m.$2, style: text.titleSmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.hits});
  final List<_SearchHit> hits;
  @override
  Widget build(BuildContext context) {
    if (hits.isEmpty) return const _NoResults();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: TastySpacing.marginPage,
        vertical: TastySpacing.stackSm,
      ),
      itemCount: hits.length,
      itemBuilder: (_, i) => _ResultTile(hit: hits[i]),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.hit});
  final _SearchHit hit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isRestaurant = hit.dish == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        child: InkWell(
          borderRadius: TastyRadii.xlRadius,
          onTap: () {
            HapticFeedback.selectionClick();
            // ALWAYS push the restaurant the result actually belongs to
            // (issue #5 fix). Dish results land on the same screen so the
            // user can add the dish from the menu.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurant: hit.restaurant),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            decoration: BoxDecoration(
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer.withValues(alpha: 0.18),
                  child: Icon(
                    isRestaurant ? Icons.storefront : Icons.local_dining,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: TastySpacing.stackMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hit.title, style: text.titleSmall),
                      Text(hit.subtitle,
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isRestaurant)
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text('${hit.restaurant.rating}',
                          style: text.titleSmall?.copyWith(color: scheme.primary)),
                    ],
                  )
                else
                  Text('\$${hit.dish!.price.toStringAsFixed(2)}',
                      style: text.titleSmall?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 40, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: TastySpacing.stackLg),
            Text('No matches', style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Try a different cuisine, restaurant, or dish name.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHit {
  const _SearchHit.restaurant(this.restaurant) : dish = null;
  const _SearchHit.dish(this.restaurant, MenuItem this.dish);
  final Restaurant restaurant;
  final MenuItem? dish;

  String get title => dish?.name ?? restaurant.name;
  String get subtitle => dish == null
      ? '${restaurant.cuisine} · ${restaurant.district} · ${restaurant.etaRange}'
      : 'from ${restaurant.name} · ${restaurant.district}';
}
