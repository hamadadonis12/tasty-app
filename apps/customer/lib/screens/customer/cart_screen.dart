import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'checkout_payment_screen.dart';

/// Cart bag — listing every line in [CartController], stepper to adjust,
/// swipe / icon to remove. Sticky "Checkout · subtotal" CTA at the bottom.
///
/// Empty-state when the cart is empty.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Your bag'),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (_, __) => cart.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      cart.clear();
                    },
                    child: const Text('Clear'),
                  ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (_, __) {
          if (cart.items.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              TastySpacing.marginPage,
              TastySpacing.stackMd,
              TastySpacing.marginPage,
              140,
            ),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _LineRow(index: i, item: cart.items[i]),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: cart,
          builder: (_, __) {
            if (cart.items.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutPaymentScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: TastyColors.brandInk,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Checkout',
                        style: text.titleSmall?.copyWith(color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: TastyColors.brandOrange,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Text('\$${cart.subtotal.toStringAsFixed(2)}',
                          style: text.titleSmall?.copyWith(color: TastyColors.brandInk)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.index, required this.item});
  final int index;
  final CartItem item;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cart = CartController.instance;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: TastyRadii.mdRadius,
            child: SizedBox(
              width: 56, height: 56,
              child: Image.network(
                item.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: text.titleSmall),
                if (item.modifier != null)
                  Text(item.modifier!,
                      style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('\$${item.lineTotal.toStringAsFixed(2)}',
                    style: text.titleSmall?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: TastyRadii.fullRadius,
            ),
            child: Row(
              children: [
                IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(item.quantity == 1 ? Icons.delete_outline : Icons.remove),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    cart.dec(index);
                  },
                ),
                Text('${item.quantity}', style: text.titleSmall),
                IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    cart.inc(index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: TastyColors.brandOrangeTint, shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 44, color: TastyColors.brandOrangeDeep),
            ),
            const SizedBox(height: TastySpacing.stackLg),
            Text('Your bag is empty',
                style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Browse restaurants and tap a dish to add it here.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TastySpacing.stackLg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse restaurants'),
              style: FilledButton.styleFrom(
                backgroundColor: TastyColors.brandOrange,
                foregroundColor: TastyColors.brandInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
