import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'coupon_wallet_screen.dart';
import 'delivery_address_setup_screen.dart';
import 'help_support_screen.dart';
import 'kinshasa_luxe_screen.dart';
import 'loyalty_rewards_screen.dart';
import 'my_favorites_screen.dart';
import 'notifications_screen.dart';
import 'order_history_screen.dart';
import 'wallet_payments_screen.dart';

/// `account_profile` — user header (avatar, name, tier), stat strip,
/// settings list grouped (Account / Activity / Preferences / Other).
class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Account'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xxlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Column(
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Edit profile photo — coming soon'),
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                          child: Icon(Icons.edit, color: scheme.onPrimary, size: 12),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text('Merveille K.', style: text.titleLarge),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TastyColors.warningContainer,
                    borderRadius: TastyRadii.fullRadius,
                  ),
                  child: Text('Gold Member',
                      style: text.labelSmall?.copyWith(
                        color: TastyColors.onWarningContainer,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(height: TastySpacing.stackMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _Stat(value: '48', label: 'Orders'),
                    _Stat(value: '8 500', label: 'Points'),
                    _Stat(value: '14', label: 'Favorites'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          _Group('ACCOUNT', [
            _Tile(icon: Icons.person_outline, title: 'Personal information', onTap: () {}),
            _Tile(
              icon: Icons.location_on_outlined,
              title: 'Saved addresses',
              value: '3',
              onTap: () => _push(context, const DeliveryAddressSetupScreen()),
            ),
            _Tile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payment methods',
              value: 'Orange Money',
              onTap: () => _push(context, const WalletPaymentsScreen()),
            ),
          ]),
          _Group('ACTIVITY', [
            _Tile(
              icon: Icons.receipt_long_outlined,
              title: 'Order history',
              onTap: () => _push(context, const OrderHistoryScreen()),
            ),
            _Tile(
              icon: Icons.favorite_border,
              title: 'My favorites',
              onTap: () => _push(context, const MyFavoritesScreen()),
            ),
            _Tile(
              icon: Icons.local_offer_outlined,
              title: 'Promotions',
              value: '3 active',
              onTap: () => _push(context, const CouponWalletScreen()),
            ),
            _Tile(
              icon: Icons.workspace_premium_outlined,
              title: 'Loyalty & Rewards',
              value: 'Gold',
              onTap: () => _push(context, const LoyaltyRewardsScreen()),
            ),
            _Tile(
              icon: Icons.diamond_outlined,
              title: 'TastyLife Luxe',
              value: 'Try free',
              onTap: () => _push(context, const KinshasaLuxeScreen()),
            ),
          ]),
          _Group('PREFERENCES', [
            _Tile(icon: Icons.language, title: 'Language', value: 'Français', onTap: () {}),
            _Tile(icon: Icons.dark_mode_outlined, title: 'Appearance', value: 'System', onTap: () {}),
            _Tile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => _push(context, const NotificationsScreen()),
            ),
          ]),
          _Group('OTHER', [
            _Tile(
              icon: Icons.help_outline,
              title: 'Help & support',
              onTap: () => _push(context, const HelpSupportScreen()),
            ),
            _Tile(icon: Icons.gavel, title: 'Legal', onTap: () {}),
            _Tile(icon: Icons.logout, title: 'Log out', danger: true, onTap: () {}),
          ]),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.label, this.children);
  final String label;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: TastySpacing.stackLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(label,
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

void _push(BuildContext context, Widget destination) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon, required this.title, this.value, this.danger = false, this.onTap,
  });
  final IconData icon;
  final String title;
  final String? value;
  final bool danger;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = danger ? scheme.error : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: text.bodyLarge?.copyWith(color: fg))),
            if (value != null) Text(value!, style: text.labelMedium),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value, style: text.titleLarge?.copyWith(color: scheme.primary)),
        Text(label, style: text.labelSmall),
      ],
    );
  }
}
