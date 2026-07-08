import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/customer/cart_screen.dart';
import '../screens/customer/delivery_address_setup_screen.dart';
import '../screens/customer/wallet_payments_screen.dart';
import '../state/app_state.dart';
import '../state/cart_controller.dart';

/// Toters-style app header: a tinted bar with the active delivery location on
/// the left and quick access to the cart and wallet on the right.
///
/// Replaces the old home top bar (avatar + wordmark + cart + bell). It pulls
/// the address from [AppState] and the cart count from [CartController], so it
/// stays live across the app. The bar paints behind the status bar (it adds
/// the top inset itself), so hosts should NOT wrap it in a top `SafeArea`.
class TastyLocationHeader extends StatelessWidget {
  const TastyLocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Warm cream tint in light mode; an elevated dark surface in dark mode so
    // the (light) text and icons stay readable instead of washing out.
    final headerBg =
        isDark ? scheme.surfaceContainerHigh : TastyColors.brandOrangeTint;

    return Container(
      color: headerBg,
      padding: EdgeInsets.fromLTRB(
        TastySpacing.marginPage,
        topInset + TastySpacing.stackSm,
        TastySpacing.marginPage,
        TastySpacing.stackMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Location selector ──
          Expanded(
            child: ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, _) {
                final s = AppState.instance;
                return InkWell(
                  borderRadius: TastyRadii.mdRadius,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (routeCtx) => DeliveryAddressSetupScreen(
                          onConfirm: () => Navigator.of(routeCtx).pop(),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              color: TastyColors.success, size: 22),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              s.addressLabel,
                              style: text.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: scheme.onSurface, size: 22),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.addressLine,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: TastySpacing.stackMd),
          // ── Carts ──
          _CartsButton(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: TastySpacing.stackMd),
          // ── Wallet balance pill ──
          _WalletPill(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletPaymentsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CartsButton extends StatelessWidget {
  const _CartsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeRing =
        isDark ? scheme.surfaceContainerHigh : TastyColors.brandOrangeTint;
    return InkWell(
      borderRadius: TastyRadii.mdRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: CartController.instance,
              builder: (context, _) {
                final count = CartController.instance.itemCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_basket_outlined,
                        color: scheme.onSurface, size: 26),
                    if (count > 0)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: TastyColors.brandOrange,
                            borderRadius: TastyRadii.fullRadius,
                            border: Border.all(color: badgeRing, width: 1.5),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text('$count',
                              textAlign: TextAlign.center,
                              style: text.labelSmall?.copyWith(
                                color: TastyColors.brandInk,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              )),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 2),
            Text('Carts',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _compactFc(AppState.instance.balanceFc),
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.account_balance_wallet_outlined,
                      color: scheme.onSurface, size: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Compact Franc balance for the pill: `45 800` → `45.8k`, `1 200 000` → `1.2M`.
  static String _compactFc(int fc) {
    if (fc >= 1000000) {
      return '${(fc / 1000000).toStringAsFixed(fc % 1000000 == 0 ? 0 : 1)}M';
    }
    if (fc >= 1000) {
      return '${(fc / 1000).toStringAsFixed(fc % 1000 == 0 ? 0 : 1)}k';
    }
    return '$fc';
  }
}
