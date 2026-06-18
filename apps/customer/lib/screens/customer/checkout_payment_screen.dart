import 'dart:ui';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'cart_screen.dart';
import 'coupon_wallet_screen.dart';
import 'delivery_address_setup_screen.dart';
import 'order_success_celebration_screen.dart';
import 'schedule_order_screen.dart';

/// `checkout_payment` — finalise the order.
///
/// Delivery address card (with map preview + edit + instructions) →
/// Delivery time (ASAP / Schedule) → Payment method (Orange Money,
/// Airtel Money, Card, Cash on Delivery) → itemised summary → sticky
/// Confirm Order CTA with the total embedded.
class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  bool _asap = true;
  int _payment = 0;
  double _tip = 0.0;
  bool _contactless = false;
  final _instructionsCtrl = TextEditingController();

  static const _delivery = 2.00;
  static const _service = 0.50;
  static const _tipOptions = <(String, double)>[
    ('No tip', 0.0),
    ('\$1', 1.0),
    ('\$2', 2.0),
    ('\$3', 3.0),
    ('\$5', 5.0),
  ];

  double get _subtotal => CartController.instance.subtotal;
  double get _total => (_subtotal + _delivery + _service + _tip - CartController.instance.discount)
      .clamp(0.0, double.infinity);

  @override
  void initState() {
    super.initState();
    // If the user landed here directly (gallery preview), seed a couple of
    // line items so the summary isn't empty.
    CartController.instance.seedIfEmpty();
  }

  static const _methods = <_Method>[
    _Method('Orange Money', '+243 89 *** **45', Icons.smartphone, Color(0xFFFF8800)),
    _Method('Airtel Money', '+243 99 *** **12', Icons.smartphone, Color(0xFFE0282E)),
    _Method('Card', 'Visa ending in 4242', Icons.credit_card, null),
    _Method('Cash on Delivery', null, Icons.payments, null),
  ];

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TastySpacing.marginPage,
          TastySpacing.stackSm,
          TastySpacing.marginPage,
          120,
        ),
        children: [
          _SectionHeader(icon: Icons.location_on, label: 'Delivery Address'),
          const SizedBox(height: TastySpacing.stackSm),
          _AddressCard(controller: _instructionsCtrl),
          const SizedBox(height: TastySpacing.sectionGap),

          _SectionHeader(icon: Icons.schedule, label: 'Delivery Time'),
          const SizedBox(height: TastySpacing.stackSm),
          Row(
            children: [
              Expanded(
                child: _TimeChoice(
                  icon: Icons.bolt,
                  title: 'ASAP',
                  sub: '15–25 min',
                  selected: _asap,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _asap = true);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeChoice(
                  icon: Icons.calendar_today,
                  title: 'Schedule',
                  sub: 'Pick a time',
                  selected: !_asap,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    setState(() => _asap = false);
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierColor: Colors.black.withValues(alpha: 0.55),
                        pageBuilder: (_, __, ___) => const ScheduleOrderScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          // Tip the driver
          _SectionHeader(icon: Icons.volunteer_activism, label: 'Tip Your Driver'),
          const SizedBox(height: TastySpacing.stackSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, opt) in _tipOptions.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _TipChip(
                    label: opt.$1,
                    selected: _tip == opt.$2,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tip = opt.$2);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          // Contactless delivery
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _contactless,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _contactless = v);
              },
              secondary: Icon(Icons.no_meeting_room, color: Theme.of(context).colorScheme.primary),
              title: const Text('Contactless delivery'),
              subtitle: const Text('Driver leaves your order at the door'),
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          _SectionHeader(icon: Icons.credit_card, label: 'Payment Method'),
          const SizedBox(height: TastySpacing.stackSm),
          for (final (i, m) in _methods.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PaymentTile(
                method: m,
                selected: _payment == i,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _payment = i);
                },
              ),
            ),
          const SizedBox(height: TastySpacing.sectionGap),

          // Order summary card
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xxlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Order Summary', style: text.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ListenableBuilder(
                  listenable: CartController.instance,
                  builder: (_, __) {
                    final items = CartController.instance.items;
                    return Column(
                      children: [
                        for (final it in items)
                          _LineItem(
                            qty: '${it.quantity}×',
                            name: it.name,
                            price: '\$${it.lineTotal.toStringAsFixed(2)}',
                          ),
                        const Divider(height: 16),
                        _SummaryRow(
                          label: 'Subtotal',
                          value: '\$${_subtotal.toStringAsFixed(2)}',
                          sub: formatCdf(_subtotal),
                        ),
                        _SummaryRow(
                          label: 'Delivery Fee',
                          value: '\$${_delivery.toStringAsFixed(2)}',
                          sub: formatCdf(_delivery),
                        ),
                        _SummaryRow(
                          label: 'Service Fee',
                          value: '\$${_service.toStringAsFixed(2)}',
                          sub: formatCdf(_service),
                        ),
                        if (_tip > 0)
                          _SummaryRow(
                            label: 'Driver Tip',
                            value: '\$${_tip.toStringAsFixed(2)}',
                            sub: formatCdf(_tip),
                          ),
                        if (CartController.instance.discount > 0)
                          _SummaryRow(
                            label: 'Loyalty Discount',
                            value: '-\$${CartController.instance.discount.toStringAsFixed(2)}',
                            color: Colors.green,
                          ),
                        const Divider(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: Text('Total', style: text.titleLarge)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${_total.toStringAsFixed(2)}',
                                    style: text.headlineSmall?.copyWith(color: scheme.primary)),
                                Text(formatCdf(_total),
                                    style: text.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: TastySpacing.stackSm),
                // Promo code
                InkWell(
                  borderRadius: TastyRadii.smRadius,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CouponWalletScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_outlined, color: scheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Apply promo code',
                              style: text.bodyMedium?.copyWith(color: scheme.primary)),
                        ),
                        Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          child: FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Snapshot the cart into an ActiveOrder so success + tracking
              // can show the customer's REAL items + total instead of a
              // hard-coded $17.50 placeholder. placeOrder() also clears
              // the cart so the badge resets.
              CartController.instance.placeOrder(
                deliveryFee: _delivery,
                serviceFee: _service,
                paymentLabel: _methods[_payment].label,
                tip: _tip,
                contactless: _contactless,
              );
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: TastyMotion.durationMd,
                  pageBuilder: (_, __, ___) => const OrderSuccessCelebrationScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: ListenableBuilder(
              listenable: CartController.instance,
              builder: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: scheme.onPrimaryContainer, size: 18),
                  const SizedBox(width: 8),
                  Text('Confirm Order  ·  \$${_total.toStringAsFixed(2)}',
                      style: text.titleSmall?.copyWith(color: scheme.onPrimaryContainer)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Method {
  const _Method(this.label, this.sub, this.icon, this.brandColor);
  final String label;
  final String? sub;
  final IconData icon;
  final Color? brandColor;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(label, style: text.titleMedium),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xxlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // Map strip
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1200&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.surfaceContainer,
                            scheme.primaryContainer.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Icon(Icons.location_on, color: scheme.primary, size: 32),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: Material(
                  color: Colors.white,
                  borderRadius: TastyRadii.fullRadius,
                  child: InkWell(
                    borderRadius: TastyRadii.fullRadius,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DeliveryAddressSetupScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text('Edit', style: text.labelMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: scheme.primary, size: 12),
                          const SizedBox(width: 4),
                          Text('Home',
                              style: text.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Avenue de la Justice, 45',
                    style: text.titleSmall),
                Text('Gombe, Kinshasa', style: text.bodyMedium),
                const SizedBox(height: TastySpacing.stackMd),
                Text('Delivery Instructions (Optional)',
                    style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ring the bell twice',
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChoice extends StatelessWidget {
  const _TimeChoice({
    required this.icon, required this.title, required this.sub,
    required this.selected, required this.onTap,
  });
  final IconData icon;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: selected ? TastyShadows.glow : TastyShadows.ambient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: selected ? scheme.onPrimaryContainer : scheme.primary, size: 20),
              const SizedBox(height: 8),
              Text(title,
                  style: text.titleSmall?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                  )),
              Text(sub,
                  style: text.labelMedium?.copyWith(
                    color: selected
                        ? scheme.onPrimaryContainer.withValues(alpha: 0.8)
                        : scheme.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.method, required this.selected, required this.onTap});
  final _Method method;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final brand = method.brandColor ?? scheme.primary;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: brand,
                  shape: BoxShape.circle,
                ),
                child: Icon(method.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.label, style: text.titleSmall),
                    if (method.sub != null) Text(method.sub!, style: text.labelMedium),
                  ],
                ),
              ),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.qty, required this.name, required this.price});
  final String qty;
  final String name;
  final String price;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: TastyRadii.smRadius,
            ),
            child: Text(qty,
                style: text.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: text.bodyMedium)),
          Text(price, style: text.titleSmall),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.color, this.sub});
  final String label;
  final String value;
  final Color? color;
  /// Optional secondary text (e.g. the CDF rendering of a USD amount).
  final String? sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = color != null ? text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold) : text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(label, style: style)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: style),
              if (sub != null)
                Text(
                  sub!,
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.fullRadius,
      child: InkWell(
        borderRadius: TastyRadii.fullRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.fullRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: text.labelLarge?.copyWith(
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
