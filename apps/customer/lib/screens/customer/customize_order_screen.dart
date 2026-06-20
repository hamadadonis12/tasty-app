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
  // One set of selected option indices per modifier group. Single-select groups
  // hold exactly one index; multi-select groups hold zero or more.
  late final List<Set<int>> _selections;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Gallery default: a representative customizable item.
    _item = widget.item ??
        RestaurantCatalog.byId('le-grill-premium').menu.firstWhere(
              (m) => m.id == 'lgp-truffle-burger',
            );
    // Single-select groups default to the first option (a radio always has one
    // chosen); multi-select groups start empty.
    _selections = [
      for (final g in _item.modifiers) g.multiSelect ? <int>{} : <int>{0},
    ];
  }

  double get _unitPrice {
    var p = _item.price;
    for (var g = 0; g < _item.modifiers.length; g++) {
      for (final i in _selections[g]) {
        p += _item.modifiers[g].options[i].priceDelta;
      }
    }
    return p;
  }

  String _selectedSummary() {
    if (_item.modifiers.isEmpty) return '';
    final parts = <String>[];
    for (var g = 0; g < _item.modifiers.length; g++) {
      final sel = _selections[g];
      if (sel.isEmpty) continue;
      final names =
          sel.map((i) => _item.modifiers[g].options[i].name).join(', ');
      parts.add('${_item.modifiers[g].name}: $names');
    }
    return parts.join(' · ');
  }

  String _deltaLabel(double d) =>
      d == 0 ? '+ \$0.00' : '+ \$${d.toStringAsFixed(2)}';

  String _groupHint(ModifierGroup g) {
    if (!g.multiSelect) return 'Select 1 option';
    if (g.maxSelect != null) return 'Choose up to ${g.maxSelect}';
    return 'Add as many as you like';
  }

  /// Builds one modifier group: a header + hint + either radio rows
  /// (single-select) or checkbox rows (multi-select, with optional cap).
  List<Widget> _buildModifierGroup(int g, TextTheme text, ColorScheme scheme) {
    final grp = _item.modifiers[g];
    final sel = _selections[g];
    final isRequired = grp.required && !grp.multiSelect;
    final atCap = grp.maxSelect != null && sel.length >= grp.maxSelect!;
    return [
      const SizedBox(height: TastySpacing.sectionGap),
      Row(
        children: [
          Expanded(child: Text(grp.name, style: text.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isRequired ? scheme.primary : scheme.surfaceContainerHighest,
              borderRadius: TastyRadii.fullRadius,
            ),
            child: Text(
              isRequired ? 'Required' : 'Optional',
              style: text.labelSmall?.copyWith(
                color: isRequired ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      Text(_groupHint(grp),
          style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 6),
      if (grp.multiSelect)
        for (var i = 0; i < grp.options.length; i++)
          CheckboxListTile(
            value: sel.contains(i),
            // Disable unchecked options once the cap is reached.
            onChanged: (!sel.contains(i) && atCap)
                ? null
                : (v) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (v ?? false) {
                        sel.add(i);
                      } else {
                        sel.remove(i);
                      }
                    });
                  },
            title: Text(grp.options[i].name),
            secondary: Text(_deltaLabel(grp.options[i].priceDelta)),
            contentPadding: EdgeInsets.zero,
            // Keep the control on the left to match the radio rows above.
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: scheme.primary,
          )
      else
        for (var i = 0; i < grp.options.length; i++)
          RadioListTile<int>(
            value: i,
            groupValue: sel.isEmpty ? -1 : sel.first,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => sel
                ..clear()
                ..add(v ?? 0));
            },
            title: Text(grp.options[i].name),
            secondary: Text(_deltaLabel(grp.options[i].priceDelta)),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: scheme.primary,
          ),
    ];
  }

  /// A fixed 40px circular glass button for the hero app bar. Stays the same
  /// size whether the SliverAppBar is expanded or collapsed (the old
  /// CircleAvatar ballooned to fill the toolbar slot on scroll).
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
                    for (var g = 0; g < _item.modifiers.length; g++)
                      ..._buildModifierGroup(g, text, scheme),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add to Cart  ·  \$${total.toStringAsFixed(2)}',
                              style: text.titleSmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
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
