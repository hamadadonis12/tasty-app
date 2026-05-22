import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'cart_screen.dart';

/// `order_history_reorder` — past orders grouped by status with one-tap
/// reorder. Top tabs (Completed / Cancelled / Drafts), cards with
/// restaurant header + items + total + big Reorder CTA.
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: Text('KINSHASA EATS',
              style: text.titleLarge?.copyWith(color: scheme.primary, letterSpacing: 1.4)),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          children: [
            Text('Order History', style: text.headlineSmall),
            const SizedBox(height: 4),
            Text('Review your past culinary journeys and quickly reorder your favorites.',
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: TastySpacing.stackLg),
            // Pill tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: TastyRadii.fullRadius,
              ),
              child: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: TastyRadii.fullRadius,
                ),
                labelColor: Colors.white,
                tabs: [Tab(text: 'Completed'), Tab(text: 'Cancelled'), Tab(text: 'Drafts')],
              ),
            ),
            const SizedBox(height: TastySpacing.stackLg),
            for (final o in _orders)
              Padding(
                padding: const EdgeInsets.only(bottom: TastySpacing.gutterCard),
                child: _OrderCard(order: o),
              ),
          ],
        ),
      ),
    );
  }
}

class _Order {
  const _Order({required this.restaurant, required this.date, required this.items, required this.total, required this.image});
  final String restaurant;
  final String date;
  final String items;
  final String total;
  final String image;
}

const _orders = <_Order>[
  _Order(
    restaurant: 'Le Relais de la Cité',
    date: 'Oct 24, 2024 · 19:30',
    items: '2× Poulet Mayo Grillé, 1× Frites Maison, 2× Coca-Cola',
    total: '\$34.50',
    image: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=200&q=80',
  ),
  _Order(
    restaurant: 'Pizzeria Napoli Gombe',
    date: 'Oct 18, 2024 · 20:15',
    items: '1× Margherita Grande, 1× Tiramisu',
    total: '\$22.00',
    image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
  ),
  _Order(
    restaurant: 'Sushi Lounge',
    date: 'Oct 12, 2024 · 21:00',
    items: '1× Dragon Roll, 1× Salmon Nigiri, 1× Edamame',
    total: '\$28.50',
    image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&q=80',
  ),
];

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _Order order;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(TastySpacing.gutterCard),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: TastyRadii.fullRadius,
                child: SizedBox(
                  width: 40, height: 40,
                  child: Image.network(order.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurant, style: text.titleSmall),
                    Text(order.date, style: text.labelMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TastyColors.successContainer.withValues(alpha: 0.6),
              borderRadius: TastyRadii.fullRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: TastyColors.onSuccessContainer),
                const SizedBox(width: 4),
                Text('Delivered',
                    style: text.labelSmall?.copyWith(
                      color: TastyColors.onSuccessContainer,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(order.items, style: text.bodyMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.download, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Download Receipt', style: text.labelMedium),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: text.labelMedium),
                    Text(order.total, style: text.titleLarge),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Reorder: re-bind cart to this restaurant and add a
                  // single line representing the past order. Demo-grade
                  // so the customer can hit checkout immediately.
                  final cart = CartController.instance;
                  cart.clear();
                  cart.setRestaurant(id: order.restaurant, name: order.restaurant);
                  cart.add(CartItem(
                    id: '${order.restaurant}-bundle',
                    name: order.items,
                    price: double.parse(order.total.replaceAll('\$', '')),
                    image: order.image,
                  ));
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reorder'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
