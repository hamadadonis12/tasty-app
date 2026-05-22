import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `my_favorites` — saved restaurants + saved dishes tabs.
class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('My Favorites'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Restaurants'), Tab(text: 'Dishes')],
          ),
        ),
        body: TabBarView(
          children: [
            _RestaurantsTab(),
            _DishesTab(),
          ],
        ),
      ),
    );
  }
}

class _RestaurantsTab extends StatelessWidget {
  static const _items = <_FavRestaurant>[
    _FavRestaurant('Maison Kinshasa', 'Congolese · 4.8 · 15 min',
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80'),
    _FavRestaurant('Le Grill Premium', 'Steakhouse · 4.7 · 25 min',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80'),
    _FavRestaurant('Sushi Lounge', 'Japanese · 4.6 · 30 min',
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=80'),
    _FavRestaurant('Mama Lina', 'Home-style · 4.9 · 20 min',
        'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=600&q=80'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(TastySpacing.marginPage),
      itemBuilder: (_, i) => _items[i],
      separatorBuilder: (_, __) => const SizedBox(height: TastySpacing.gutterCard),
      itemCount: _items.length,
    );
  }
}

class _FavRestaurant extends StatelessWidget {
  const _FavRestaurant(this.name, this.meta, this.image);
  final String name;
  final String meta;
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(TastyRadii.xl)),
            child: SizedBox(
              width: 90,
              height: 90,
              child: Image.network(image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.stackMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(meta, style: text.bodySmall),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: scheme.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _DishesTab extends StatelessWidget {
  static const _items = <(String, String, String)>[
    ('Poulet Moambe', 'Maison Kinshasa · \$12.50',
        'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=600&q=80'),
    ('Truffle Burger', 'Le Grill Premium · \$18.00',
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80'),
    ('Salmon Nigiri', 'Sushi Lounge · \$22.00',
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=80'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return GridView.builder(
      padding: const EdgeInsets.all(TastySpacing.marginPage),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final d = _items[i];
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
                  aspectRatio: 1.2,
                  child: Image.network(d.$3, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.$1, style: text.titleSmall),
                    const SizedBox(height: 4),
                    Text(d.$2, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
