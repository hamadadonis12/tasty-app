import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '_kitchen_shell.dart';

/// `inventory_menu_manager` — menu management: tabs (Active / Specials /
/// Archived), grid of menu items with photo + price + in-stock toggle.
class MenuManagerScreen extends StatelessWidget {
  const MenuManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: KitchenShell(
        activeKey: 'menu',
        title: 'Menu Management',
        subtitle: 'Update inventory and availability in real-time',
        headerTrailing: [
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu items…',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Active Menu'),
                Tab(text: 'Daily Specials'),
                Tab(text: 'Archived'),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: TabBarView(
                children: [
                  _MenuGrid(items: _active),
                  _MenuGrid(items: _specials),
                  _MenuGrid(items: _archived),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items});
  final List<_Item> items;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mains', style: text.titleSmall),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 90,
            ),
            itemBuilder: (_, i) => items[i],
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _Item extends StatefulWidget {
  const _Item({required this.name, required this.desc, required this.price, required this.image, required this.inStock});
  final String name;
  final String desc;
  final String price;
  final String image;
  final bool inStock;
  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  late bool _inStock = widget.inStock;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return KitchenCard(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(TastyRadii.xl)),
                child: SizedBox(
                  width: 70, height: 90,
                  child: Image.network(widget.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
                ),
              ),
              if (!_inStock)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.7),
                    alignment: Alignment.center,
                    child: Text('Sold Out',
                        style: text.labelSmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.name, style: text.titleSmall, overflow: TextOverflow.ellipsis),
                      ),
                      Text(widget.price,
                          style: text.titleSmall?.copyWith(color: scheme.primary)),
                    ],
                  ),
                  Text(widget.desc,
                      style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    children: [
                      Text('STATUS',
                          style: text.labelSmall?.copyWith(letterSpacing: 1.2, color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Switch(value: _inStock, onChanged: (v) => setState(() => _inStock = v)),
                      Text(_inStock ? 'In Stock' : 'Sold Out', style: text.labelMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

final _active = <_Item>[
  _Item(name: 'Kinshasa Chicken', desc: 'Grilled chicken, signature sauce',
      price: '\$18.50', inStock: true,
      image: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=400&q=80'),
  _Item(name: 'Liboke de Poisson', desc: 'Steamed fish, traditional pondu',
      price: '\$22.00', inStock: true,
      image: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=80'),
  _Item(name: 'Grilled Capitaine', desc: 'Fresh river fish, lemon butter',
      price: '\$26.00', inStock: false,
      image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80'),
  _Item(name: 'Pondu Spécial', desc: 'Cassava leaves, smoked fish',
      price: '\$14.50', inStock: true,
      image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80'),
];

final _specials = <_Item>[
  _Item(name: 'Weekend Feast', desc: 'Family-style platter, 4 mains',
      price: '\$45.00', inStock: true,
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80'),
];

final _archived = <_Item>[
  _Item(name: 'Old Burger Combo', desc: 'Discontinued 2025-01-20',
      price: '\$12.00', inStock: false,
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
];
