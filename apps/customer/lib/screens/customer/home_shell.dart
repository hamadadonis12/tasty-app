import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'account_profile_screen.dart';
import 'immersive_home_screen.dart';
import 'live_order_tracking_screen.dart';
import 'order_history_screen.dart';
import 'smart_search_screen.dart';
import 'wallet_payments_screen.dart';

/// Five-tab production shell that owns the bottom nav.
///
/// Wraps the existing tab-content screens in an [IndexedStack] so each tab
/// preserves its scroll position and state when the user switches away
/// and back. When an order is in progress, a slim active-order bar sits
/// above the bottom nav so customers can jump back to the tracker from
/// any tab (PRD FR-C-011).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    ImmersiveHomeScreen(hideBottomNav: true),
    SmartSearchScreen(),
    OrderHistoryScreen(),
    WalletPaymentsScreen(),
    AccountProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (context, _) {
              final order = CartController.instance.activeOrder;
              if (order == null) return const SizedBox.shrink();
              return _ActiveOrderBar(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LiveOrderTrackingScreen(),
                    ),
                  );
                },
              );
            },
          ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              setState(() => _index = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderBar extends StatelessWidget {
  const _ActiveOrderBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final order = CartController.instance.activeOrder!;
    final stage = CartController.instance.simStage;

    String label = 'Order placed · Tap to track';
    IconData icon = Icons.receipt_long;
    if (stage == 'preparing') {
      label = 'Chef is preparing your order';
      icon = Icons.restaurant_menu;
    } else if (stage == 'outForDelivery') {
      label = '${order.driverName} is on the way';
      icon = Icons.pedal_bike;
    } else if (stage == 'arrived') {
      label = '${order.driverName} has arrived · PIN ${order.verificationPin}';
      icon = Icons.pin_drop;
    }

    return Material(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: scheme.onPrimaryContainer, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ACTIVE ORDER · ${order.orderId}',
                      style: text.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      label,
                      style: text.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
