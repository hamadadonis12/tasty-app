import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/cart_controller.dart';
import 'appearance_settings_screen.dart';
import 'coupon_wallet_screen.dart';
import 'delivery_address_setup_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'kinshasa_luxe_screen.dart';
import 'language_settings_screen.dart';
import 'legal_screen.dart';
import 'loyalty_rewards_screen.dart';
import 'my_favorites_screen.dart';
import 'notifications_screen.dart';
import 'order_history_screen.dart';
import 'profile_photo_picker.dart';
import 'settings_screen.dart';
import 'wallet_payments_screen.dart';

void _confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to place orders.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Logged out (demo) — onboarding flow would restart here'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(context, const SettingsScreen()),
          ),
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
                  onTap: () => showProfilePhotoPicker(context),
                  child: Stack(
                    children: [
                      const ProfileAvatar(radius: 36),
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
                ListenableBuilder(
                  listenable: AppState.instance,
                  builder: (ctx, _) => Text(AppState.instance.name, style: text.titleLarge),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TastyColors.warningContainer,
                    borderRadius: TastyRadii.fullRadius,
                  ),
                  child: Text(AppState.instance.memberTier,
                      style: text.labelSmall?.copyWith(
                        color: TastyColors.onWarningContainer,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(height: TastySpacing.stackMd),
                ListenableBuilder(
                  listenable: CartController.instance,
                  builder: (ctx, _) {
                    final cart = CartController.instance;
                    String fmt(int n) {
                      final s = n.toString();
                      final buf = StringBuffer();
                      for (int i = 0; i < s.length; i++) {
                        if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
                        buf.write(s[i]);
                      }
                      return buf.toString();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(value: '${cart.pastOrders.length}', label: 'Orders'),
                        _Stat(value: fmt(cart.loyaltyPoints), label: 'Points'),
                        _Stat(value: '${cart.favoriteCount}', label: 'Favorites'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          _Group('ACCOUNT', [
            _Tile(
              icon: Icons.person_outline,
              title: 'Personal information',
              onTap: () => _push(context, const EditProfileScreen()),
            ),
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
            ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, _) => _Tile(
                icon: Icons.language,
                title: 'Language',
                value: AppState.instance.language.label,
                onTap: () => _push(context, const LanguageSettingsScreen()),
              ),
            ),
            ListenableBuilder(
              listenable: AppState.instance,
              builder: (context, _) => _Tile(
                icon: Icons.dark_mode_outlined,
                title: 'Appearance',
                value: AppState.instance.themeModeLabel,
                onTap: () => _push(context, const AppearanceSettingsScreen()),
              ),
            ),
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
            _Tile(
              icon: Icons.gavel,
              title: 'Legal',
              onTap: () => _push(context, const LegalScreen()),
            ),
            _Tile(
              icon: Icons.logout,
              title: 'Log out',
              danger: true,
              onTap: () => _confirmLogout(context),
            ),
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
