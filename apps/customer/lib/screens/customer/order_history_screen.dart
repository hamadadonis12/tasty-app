import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/receipt_pdf.dart';
import '../../state/cart_controller.dart';
import 'cart_screen.dart';
import 'live_order_tracking_screen.dart';
import 'order_details_screen.dart';

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
          automaticallyImplyLeading: false,
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
            // Live active order tracking card (interactive navigation link)
            ListenableBuilder(
              listenable: CartController.instance,
              builder: (context, _) {
                final order = CartController.instance.activeOrder;
                if (order == null) return const SizedBox.shrink();
                
                final progress = CartController.instance.simProgress;
                final stageStr = CartController.instance.simStage;
                
                String stageLabel = 'Preparing Order';
                IconData stageIcon = Icons.restaurant_menu;
                double barVal = 0.35;
                
                if (stageStr == 'placed') {
                  stageLabel = 'Order Placed';
                  stageIcon = Icons.receipt_long;
                  barVal = 0.15;
                } else if (stageStr == 'preparing') {
                  stageLabel = 'Preparing Food';
                  stageIcon = Icons.restaurant;
                  barVal = 0.40;
                } else if (stageStr == 'outForDelivery') {
                  stageLabel = 'Rider is on the Way!';
                  stageIcon = Icons.pedal_bike;
                  barVal = 0.4 + 0.5 * ((progress - 0.35) / 0.55);
                } else if (stageStr == 'arrived') {
                  stageLabel = 'Driver Outside!';
                  stageIcon = Icons.pin_drop;
                  barVal = 1.0;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: TastySpacing.gutterCard),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: TastyRadii.xlRadius,
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.35), width: 1.5),
                    boxShadow: TastyShadows.ambient,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(stageIcon, color: scheme.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ACTIVE ORDER IN PROGRESS',
                                    style: text.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    )),
                                const SizedBox(height: 2),
                                Text(order.restaurantName,
                                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: stageStr == 'arrived' ? TastyColors.successContainer : scheme.primaryContainer,
                              borderRadius: TastyRadii.fullRadius,
                            ),
                            child: Text(
                              stageLabel,
                              style: text.labelSmall?.copyWith(
                                color: stageStr == 'arrived' ? TastyColors.onSuccessContainer : scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: TastyRadii.fullRadius,
                        child: LinearProgressIndicator(
                          value: barVal.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: scheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Total: \$${order.total.toStringAsFixed(2)}',
                            style: text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LiveOrderTrackingScreen()),
                              );
                            },
                            icon: const Icon(Icons.gps_fixed, size: 14),
                            label: const Text('Open Tracker'),
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              minimumSize: const Size(110, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            ListenableBuilder(
              listenable: CartController.instance,
              builder: (context, _) {
                final pastOrders = CartController.instance.pastOrders;
                return Column(
                  children: [
                    for (final o in pastOrders)
                      Padding(
                        padding: const EdgeInsets.only(bottom: TastySpacing.gutterCard),
                        child: _OrderCard(order: o),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderHistoryItem order;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
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
                    Text(order.restaurantName, style: text.titleSmall),
                    Text(order.date, style: text.labelMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
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
          Text(order.itemsDescription, style: text.bodyMedium),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: TastyRadii.smRadius,
            onTap: () async {
              HapticFeedback.lightImpact();
              final messenger = ScaffoldMessenger.of(context);
              try {
                await shareReceiptPdf(order);
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Could not generate receipt: $e'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.download, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Download Receipt', style: text.labelMedium),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: text.labelMedium),
                  Text('\$${order.total.toStringAsFixed(2)}', style: text.titleLarge),
                ],
              ),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final cart = CartController.instance;
                  cart.clear();
                  cart.setRestaurant(id: order.restaurantName, name: order.restaurantName);
                  if (order.items.isNotEmpty) {
                    for (final item in order.items) {
                      cart.add(item);
                    }
                  } else {
                    cart.add(CartItem(
                      id: '${order.restaurantName}-bundle',
                      name: order.itemsDescription,
                      price: order.total,
                      image: order.image,
                    ));
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  minimumSize: const Size(120, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 6),
                    Text('Reorder'),
                  ],
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
