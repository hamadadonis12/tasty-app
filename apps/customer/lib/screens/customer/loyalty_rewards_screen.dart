import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'notifications_screen.dart';

/// `loyalty_rewards_hub` — Gold member tier card, perks grid, available
/// rewards list, refer-and-earn footer.
///
/// All interactive elements are wired to real state on [CartController]
/// (loyalty points, redeemed rewards, applied discount). Redeeming a
/// reward debits points and adds a credit to the next checkout.
class LoyaltyRewardsScreen extends StatefulWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  State<LoyaltyRewardsScreen> createState() => _LoyaltyRewardsScreenState();
}

class _LoyaltyRewardsScreenState extends State<LoyaltyRewardsScreen> {
  bool _expanded = false;
  static const _referralCode = 'MERVEILLE-K-2026';

  // Catalogue of rewards. First 2 always shown, the rest unlock on VIEW ALL.
  static const _allRewards = <_RewardData>[
    _RewardData(
      id: 'burger-combo',
      name: 'Signature Burger Combo',
      sub: 'Includes fries and a drink.',
      cost: 2000,
      creditUsd: 8.00,
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    ),
    _RewardData(
      id: 'pizza-credit',
      name: '\$15 Off Any Artisan Pizza',
      sub: 'Valid for dinner orders only.',
      cost: 3500,
      creditUsd: 15.00,
      image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    ),
    _RewardData(
      id: 'sushi-platter',
      name: 'Sushi Platter for Two',
      sub: 'From Sushi Lounge · 20 pieces',
      cost: 4500,
      creditUsd: 22.00,
      image: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&q=80',
    ),
    _RewardData(
      id: 'free-delivery-month',
      name: 'Free Delivery · 30 days',
      sub: 'Unlimited free delivery in May',
      cost: 6000,
      creditUsd: 30.00,
      image: 'https://images.unsplash.com/photo-1574871786514-46e2eb6f4a9b?w=400&q=80',
    ),
    _RewardData(
      id: 'birthday-cake',
      name: 'Maison Kinshasa Birthday Cake',
      sub: 'Whole cake · serves 8',
      cost: 7500,
      creditUsd: 35.00,
      image: 'https://images.unsplash.com/photo-1535141192574-5d4897c12636?w=400&q=80',
    ),
  ];

  static const _perks = <_PerkData>[
    _PerkData(
      icon: Icons.delivery_dining,
      title: 'Free Delivery',
      sub: 'On all orders over \$30',
      info: 'Every order over \$30 has its delivery fee waived automatically — no code, no minimum frequency. Stacks with promo codes.',
    ),
    _PerkData(
      icon: Icons.headset_mic,
      title: 'Priority Support',
      sub: '24/7 dedicated line',
      info: 'Gold members get a dedicated support phone number (+243 89 *** **45). Average reply time: under 90 seconds.',
    ),
    _PerkData(
      icon: Icons.cake,
      title: 'Birthday Treat',
      sub: 'Complimentary dessert',
      info: 'On your birthday week, every order over \$15 gets a complimentary dessert chosen by the restaurant — at no charge.',
    ),
    _PerkData(
      icon: Icons.star_rounded,
      title: 'Early Access',
      sub: 'To new menus & pop-ups',
      info: 'Gold members see new restaurants and pop-up events 48 hours before the general public, and can pre-book limited seats.',
    ),
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void _onRedeem(_RewardData r) {
    HapticFeedback.mediumImpact();
    final cart = CartController.instance;
    if (cart.isRewardRedeemed(r.id)) {
      _toast('${r.name} already redeemed — applied to your next order.');
      return;
    }
    if (cart.loyaltyPoints < r.cost) {
      _toast('You need ${r.cost - cart.loyaltyPoints} more points to redeem this.');
      return;
    }
    cart.redeemReward(id: r.id, cost: r.cost, creditUsd: r.creditUsd);
    _toast('Redeemed ${r.name} · \$${r.creditUsd.toStringAsFixed(0)} credit applied at checkout');
  }

  void _showPerkInfo(_PerkData p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(p.icon, color: Theme.of(ctx).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(p.title, style: Theme.of(ctx).textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.info, style: Theme.of(ctx).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _shareReferral() {
    HapticFeedback.lightImpact();
    Clipboard.setData(const ClipboardData(text: _referralCode));
    _toast('Referral code $_referralCode copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('TastyLife', style: text.titleLarge?.copyWith(color: scheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final points = CartController.instance.loyaltyPoints;
          final toNext = CartController.instance.pointsToNextTier;
          final tierProgress = (points / CartController.loyaltyTierTarget).clamp(0.0, 1.0);
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              Text('Loyalty & Rewards', style: text.headlineSmall),
              const SizedBox(height: 4),
              Text('Your journey to exquisite experiences.',
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: TastySpacing.stackLg),
              // Tier card — live points + progress
              Container(
                padding: const EdgeInsets.all(TastySpacing.gutterCard),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primaryContainer, scheme.primary],
                  ),
                  borderRadius: TastyRadii.xxlRadius,
                  boxShadow: TastyShadows.glow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('CURRENT TIER',
                            style: text.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 1.4,
                            )),
                        const Spacer(),
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    Text('Gold Member', style: text.headlineSmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(_formatPoints(points),
                            style: text.displaySmall?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 6),
                        Text('pts',
                            style: text.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                        const Spacer(),
                        Text(
                          toNext == 0 ? 'Max tier reached!' : '${_formatPoints(toNext)} pts to Platinum',
                          style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: TastyRadii.fullRadius,
                      child: LinearProgressIndicator(
                        value: tierProgress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Text('Your Exclusive Perks', style: text.titleMedium),
              const SizedBox(height: TastySpacing.stackMd),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final p in _perks)
                    _Perk(data: p, onTap: () => _showPerkInfo(p)),
                ],
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Row(
                children: [
                  Text('Available Rewards', style: text.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _expanded = !_expanded);
                    },
                    child: Text(_expanded ? 'SHOW LESS' : 'VIEW ALL'),
                  ),
                ],
              ),
              const SizedBox(height: TastySpacing.stackSm),
              for (final r in (_expanded ? _allRewards : _allRewards.take(2)))
                _Reward(
                  data: r,
                  redeemed: CartController.instance.isRewardRedeemed(r.id),
                  canAfford: points >= r.cost,
                  onRedeem: () => _onRedeem(r),
                ),
              const SizedBox(height: TastySpacing.sectionGap),
              // Refer & earn — share now actually copies a real code
              Container(
                padding: const EdgeInsets.all(TastySpacing.gutterCard),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: TastyRadii.xxlRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group_add, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text('Refer & Earn Big', style: text.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share your love for TastyLife. Give friends \$10 off their first order, '
                      'and get 5,000 points when they order.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: TastyRadii.mdRadius,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tag, size: 16, color: scheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _referralCode,
                              style: text.titleSmall?.copyWith(
                                fontFamily: 'JetBrains Mono',
                                color: scheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TastySpacing.stackMd),
                    FilledButton.icon(
                      onPressed: _shareReferral,
                      icon: const Icon(Icons.share),
                      label: const Text('Copy Invite Code'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatPoints(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PerkData {
  const _PerkData({
    required this.icon,
    required this.title,
    required this.sub,
    required this.info,
  });
  final IconData icon;
  final String title;
  final String sub;
  final String info;
}

class _Perk extends StatelessWidget {
  const _Perk({required this.data, required this.onTap});
  final _PerkData data;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(data.icon, color: scheme.primary, size: 16),
              ),
              const Spacer(),
              Text(data.title, style: text.titleSmall),
              Text(data.sub, style: text.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardData {
  const _RewardData({
    required this.id,
    required this.name,
    required this.sub,
    required this.cost,
    required this.creditUsd,
    required this.image,
  });
  final String id;
  final String name;
  final String sub;
  final int cost;
  final double creditUsd;
  final String image;
}

class _Reward extends StatelessWidget {
  const _Reward({
    required this.data,
    required this.redeemed,
    required this.canAfford,
    required this.onRedeem,
  });
  final _RewardData data;
  final bool redeemed;
  final bool canAfford;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final disabled = redeemed || !canAfford;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: TastyRadii.lgRadius,
            child: SizedBox(
              width: 64, height: 64,
              child: Image.network(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: text.titleSmall),
                Text(data.sub, style: text.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${data.cost} pts',
                  style: text.titleSmall?.copyWith(color: scheme.primary)),
              const SizedBox(height: 4),
              FilledButton(
                onPressed: redeemed ? null : (canAfford ? onRedeem : onRedeem),
                style: FilledButton.styleFrom(
                  backgroundColor: redeemed
                      ? TastyColors.success
                      : (canAfford ? scheme.primary : scheme.surfaceContainerHigh),
                  foregroundColor: redeemed
                      ? Colors.white
                      : (canAfford ? scheme.onPrimary : scheme.onSurfaceVariant),
                  minimumSize: const Size(96, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  redeemed
                      ? 'Redeemed'
                      : (canAfford ? 'Redeem' : 'Need more'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
