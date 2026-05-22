import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import '../../state/cart_controller.dart';

/// `customize_your_order` — bottom-sheet-style product detail.
///
/// Now driven by a passed-in [MenuItem] so tapping "Poulet Moambe" actually
/// shows Poulet Moambe (not the Truffle Mushroom Burger). Falls back to
/// the demo burger when constructed without arguments (gallery mode).
class CustomizeOrderScreen extends StatefulWidget {
  const CustomizeOrderScreen({super.key, this.item, this.restaurantName});
  final MenuItem? item;
  final String? restaurantName;
  @override
  State<CustomizeOrderScreen> createState() => _CustomizeOrderScreenState();
}

class _CustomizeOrderScreenState extends State<CustomizeOrderScreen> {
  late final MenuItem _item;
  late final List<int> _selectedByGroup; // one selected option index per modifier group
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Gallery default: a representative customizable item.
    _item = widget.item ??
        RestaurantCatalog.byId('le-grill-premium').menu.firstWhere(
              (m) => m.id == 'lgp-truffle-burger',
            );
    _selectedByGroup = List<int>.filled(_item.modifiers.length, 0);
  }

  double get _unitPrice {
    var p = _item.price;
    for (var g = 0; g < _item.modifiers.length; g++) {
      final opt = _item.modifiers[g].options[_selectedByGroup[g]];
      p += opt.priceDelta;
    }
    return p;
  }

  String _selectedSummary() {
    if (_item.modifiers.isEmpty) return '';
    final parts = <String>[];
    for (var g = 0; g < _item.modifiers.length; g++) {
      final opt = _item.modifiers[g].options[_selectedByGroup[g]];
      parts.add('${_item.modifiers[g].name}: ${opt.name}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final total = _unitPrice * _quantity;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.95),
                  child: const BackButton(),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.95),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: HapticFeedback.lightImpact,
                    ),
                  ),
                  const SizedBox(width: TastySpacing.stackMd),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    _item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  TastySpacing.marginPage,
                  TastySpacing.stackLg,
                  TastySpacing.marginPage,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(_item.name, style: text.headlineSmall)),
                        Text('\$${_item.price.toStringAsFixed(2)}',
                            style: text.headlineSmall?.copyWith(color: scheme.primary)),
                      ],
                    ),
                    if (widget.restaurantName != null) ...[
                      const SizedBox(height: 4),
                      Text('from ${widget.restaurantName}',
                          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _item.description,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (_item.modifiers.isEmpty) ...[
                      const SizedBox(height: TastySpacing.sectionGap),
                      Container(
                        padding: const EdgeInsets.all(TastySpacing.stackMd),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: TastyRadii.lgRadius,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('No options to customize for this dish.',
                                  style: text.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ],
                    for (var g = 0; g < _item.modifiers.length; g++) ...[
                      const SizedBox(height: TastySpacing.sectionGap),
                      Row(
                        children: [
                          Text(_item.modifiers[g].name, style: text.titleSmall),
                          const Spacer(),
                          if (_item.modifiers[g].required)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: TastyRadii.fullRadius,
                              ),
                              child: Text('Required',
                                  style: text.labelSmall?.copyWith(color: scheme.onPrimary)),
                            ),
                        ],
                      ),
                      Text('Select 1 option', style: text.labelMedium),
                      const SizedBox(height: 6),
                      for (var i = 0; i < _item.modifiers[g].options.length; i++)
                        RadioListTile<int>(
                          value: i,
                          groupValue: _selectedByGroup[g],
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedByGroup[g] = v ?? 0);
                          },
                          title: Text(_item.modifiers[g].options[i].name),
                          secondary: Text(
                            _item.modifiers[g].options[i].priceDelta == 0
                                ? '+ \$0.00'
                                : '+ \$${_item.modifiers[g].options[i].priceDelta.toStringAsFixed(2)}',
                          ),
                          contentPadding: EdgeInsets.zero,
                          activeColor: scheme.primary,
                        ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          // Sticky add-to-cart bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                TastySpacing.marginPage,
                TastySpacing.stackMd,
                TastySpacing.marginPage,
                TastySpacing.stackLg,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                boxShadow: TastyShadows.sheet,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _quantity--);
                                  }
                                : null,
                          ),
                          AnimatedSwitcher(
                            duration: TastyMotion.durationSm,
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: Text('$_quantity',
                                key: ValueKey(_quantity), style: text.titleMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          CartController.instance.add(CartItem(
                            id: _item.id,
                            name: _item.name,
                            price: _unitPrice,
                            image: _item.image,
                            modifier: _selectedSummary().isEmpty ? null : _selectedSummary(),
                            quantity: _quantity,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Added $_quantity × ${_item.name} to your bag'),
                            duration: const Duration(seconds: 2),
                          ));
                          Navigator.of(context).maybePop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          children: [
                            const Text('Add to Cart'),
                            const Spacer(),
                            AnimatedSwitcher(
                              duration: TastyMotion.durationSm,
                              child: Text('\$${total.toStringAsFixed(2)}',
                                  key: ValueKey(total),
                                  style: text.titleSmall?.copyWith(color: scheme.onPrimaryContainer)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
