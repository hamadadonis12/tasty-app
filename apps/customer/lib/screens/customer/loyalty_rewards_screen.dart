import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `loyalty_rewards_hub` — Gold member tier card, perks grid, available
/// rewards list, refer-and-earn footer.
class LoyaltyRewardsScreen extends StatelessWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('TastyLife',
            style: text.titleLarge?.copyWith(color: scheme.primary)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          Text('Loyalty & Rewards', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text('Your journey to exquisite experiences.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: TastySpacing.stackLg),
          // Tier card
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
                Text('Gold Member',
                    style: text.headlineSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('12,450',
                        style: text.displaySmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Text('pts',
                        style: text.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                    const Spacer(),
                    Text('2,550 pts to Platinum',
                        style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: TastyRadii.fullRadius,
                  child: LinearProgressIndicator(
                    value: 12450 / 15000,
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
            children: const [
              _Perk(icon: Icons.delivery_dining, title: 'Free Delivery', sub: 'On all orders over \$30'),
              _Perk(icon: Icons.headset_mic, title: 'Priority Support', sub: '24/7 dedicated line'),
              _Perk(icon: Icons.cake, title: 'Birthday Treat', sub: 'Complimentary dessert'),
              _Perk(icon: Icons.star_rounded, title: 'Early Access', sub: 'To new menus & pop-ups'),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Row(
            children: [
              Text('Available Rewards', style: text.titleMedium),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('VIEW ALL')),
            ],
          ),
          const SizedBox(height: TastySpacing.stackSm),
          _Reward(
            name: 'Signature Burger Combo',
            sub: 'Includes fries and a drink.',
            cost: '2,000 pts',
            image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
          ),
          _Reward(
            name: '\$15 Off Any Artisan Pizza',
            sub: 'Valid for dinner orders only.',
            cost: '3,500 pts',
            image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          // Refer & earn
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
                const SizedBox(height: TastySpacing.stackMd),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share Invite Link'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
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

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: scheme.primary, size: 16),
          ),
          const Spacer(),
          Text(title, style: text.titleSmall),
          Text(sub, style: text.labelSmall),
        ],
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.name, required this.sub, required this.cost, required this.image});
  final String name;
  final String sub;
  final String cost;
  final String image;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: TastyRadii.lgRadius,
            child: SizedBox(
              width: 64, height: 64,
              child: Image.network(image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleSmall),
                Text(sub, style: text.labelMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cost, style: text.titleSmall?.copyWith(color: scheme.primary)),
              const SizedBox(height: 4),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  minimumSize: const Size(80, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Redeem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
