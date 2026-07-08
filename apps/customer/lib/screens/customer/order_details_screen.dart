import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/receipt_pdf.dart';
import '../../state/cart_controller.dart';
import 'cart_screen.dart';

/// `order_details` — full breakdown of a past order: what you ordered, how it
/// reached you (driver + delivery), the cost breakdown, and a one-tap receipt
/// download. Reached by tapping any card in the order history.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});
  final OrderHistoryItem order;

  String _fc(double usd) {
    final digits = (usd * kUsdToCdf).round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return '$buf FC';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Order details'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TastySpacing.marginPage,
          TastySpacing.stackMd,
          TastySpacing.marginPage,
          140,
        ),
        children: [
          _restaurantHeader(scheme, text),
          const SizedBox(height: TastySpacing.gutterCard),
          _section('Your order', scheme, text),
          const SizedBox(height: 8),
          _orderItems(scheme, text),
          const SizedBox(height: TastySpacing.gutterCard),
          _section('How it got to you', scheme, text),
          const SizedBox(height: 8),
          _deliveryCard(scheme, text),
          const SizedBox(height: TastySpacing.gutterCard),
          _section('Payment', scheme, text),
          const SizedBox(height: 8),
          _costBreakdown(scheme, text),
        ],
      ),
      bottomNavigationBar: _bottomBar(context, scheme, text),
    );
  }

  Widget _section(String label, ColorScheme scheme, TextTheme text) => Text(
        label.toUpperCase(),
        style: text.labelMedium
            ?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.0),
      );

  Widget _card({required Widget child, required ColorScheme scheme}) => Container(
        padding: const EdgeInsets.all(TastySpacing.gutterCard),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: TastyRadii.xlRadius,
          boxShadow: TastyShadows.ambient,
        ),
        child: child,
      );

  Widget _restaurantHeader(ColorScheme scheme, TextTheme text) => _card(
        scheme: scheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: TastyRadii.fullRadius,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(order.image, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: scheme.surfaceContainer)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: text.titleSmall),
                      Text('${order.date}  ·  #${order.orderId}',
                          style: text.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
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
                  Icon(Icons.check_circle,
                      size: 14, color: TastyColors.onSuccessContainer),
                  const SizedBox(width: 4),
                  Text('Delivered',
                      style: text.labelSmall?.copyWith(
                        color: TastyColors.onSuccessContainer,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _orderItems(ColorScheme scheme, TextTheme text) {
    // Rich rows when the order carries CartItems; otherwise fall back to
    // splitting the "2× X, 1× Y" description so older orders still itemise.
    final rows = <Widget>[];
    if (order.items.isNotEmpty) {
      for (final it in order.items) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text('${it.quantity}×',
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.name, style: text.bodyMedium),
                    if (it.modifier != null)
                      Text(it.modifier!,
                          style: text.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('\$${it.lineTotal.toStringAsFixed(2)}',
                  style: text.bodyMedium),
            ],
          ),
        ));
      }
    } else {
      final lines = order.itemsDescription
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      for (final l in lines) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.circle, size: 6, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(l, style: text.bodyMedium)),
            ],
          ),
        ));
      }
    }
    return _card(
      scheme: scheme,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }

  Widget _deliveryCard(ColorScheme scheme, TextTheme text) {
    final hasDriver = order.driverName.isNotEmpty;
    return _card(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDriver) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(order.driverInitials,
                      style: text.titleSmall
                          ?.copyWith(color: scheme.onPrimaryContainer)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.driverName, style: text.titleSmall),
                      Text(
                        order.driverVehicle.isEmpty
                            ? 'Your rider'
                            : order.driverVehicle,
                        style: text.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.pedal_bike, color: scheme.primary),
              ],
            ),
            const Divider(height: 24),
          ],
          if (order.deliveryAddress.isNotEmpty)
            _infoRow(Icons.location_on_outlined, 'Delivered to',
                order.deliveryAddress, scheme, text),
          _infoRow(Icons.verified_outlined, 'Confirmation PIN',
              order.verificationPin, scheme, text),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ColorScheme scheme,
          TextTheme text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: Text(label,
                  style: text.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ),
            Expanded(child: Text(value, style: text.bodyMedium)),
          ],
        ),
      );

  Widget _costBreakdown(ColorScheme scheme, TextTheme text) => _card(
        scheme: scheme,
        child: Column(
          children: [
            _infoRow(Icons.credit_card, 'Paid with', order.paymentLabel,
                scheme, text),
            const Divider(height: 24),
            _amountRow('Subtotal', order.subtotal, scheme, text),
            if (order.deliveryFee > 0)
              _amountRow('Delivery fee', order.deliveryFee, scheme, text),
            if (order.serviceFee > 0)
              _amountRow('Service fee', order.serviceFee, scheme, text),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total', style: text.titleMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${order.total.toStringAsFixed(2)}',
                        style: text.titleLarge
                            ?.copyWith(color: scheme.primary)),
                    Text(_fc(order.total),
                        style: text.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _amountRow(
          String label, double amount, ColorScheme scheme, TextTheme text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            Text('\$${amount.toStringAsFixed(2)}', style: text.bodyMedium),
          ],
        ),
      );

  Widget _bottomBar(BuildContext context, ColorScheme scheme, TextTheme text) =>
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
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
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Receipt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(color: scheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final cart = CartController.instance;
                    cart.clear();
                    cart.setRestaurant(
                        id: order.restaurantName, name: order.restaurantName);
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
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reorder'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
