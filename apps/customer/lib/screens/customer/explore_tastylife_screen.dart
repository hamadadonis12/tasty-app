import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `explore_tastylife` — the editorial feed.
///
/// This is the differentiator UX agent identified: a magazine-style feed
/// curated weekly. Hero feature story, then editorial cards with chef /
/// neighborhood / cuisine narratives.
class ExploreTastyLifeScreen extends StatelessWidget {
  const ExploreTastyLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
            title: const Text('TastyLife'),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TastySpacing.marginPage,
                TastySpacing.stackSm,
                TastySpacing.marginPage,
                TastySpacing.stackLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THE ISSUE · MAY 22',
                      style: text.labelMedium?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  Text('Eat Like a Local',
                      style: text.displaySmall?.copyWith(height: 1.05)),
                  const SizedBox(height: 6),
                  Text(
                    'A weekly editorial guide to Kinshasa\'s living kitchens — '
                    'the people, dishes, and corners worth your hunger.',
                    style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _FeatureStory()),
          const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            sliver: SliverToBoxAdapter(
              child: Text('Chef stories this week', style: text.titleMedium),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.stackMd)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
            sliver: SliverList.separated(
              itemBuilder: (_, i) => _EditorialCard(item: _stories[i]),
              separatorBuilder: (_, __) => const SizedBox(height: TastySpacing.gutterCard),
              itemCount: _stories.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TastySpacing.sectionGap)),
        ],
      ),
    );
  }
}

class _FeatureStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: TastyRadii.xxlRadius,
          boxShadow: TastyShadows.ambient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: _imageFallback,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THE FEATURE',
                      style: text.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 6),
                  Text('How Mama Lina re-invented Poulet Moambe',
                      style: text.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Twenty-three years behind a clay pot in Lingwala. We spent '
                    'an evening following her recipe — and the diaspora who fly '
                    'home for it.',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('by Paul-Henri', style: text.labelMedium),
                      const Spacer(),
                      Icon(Icons.access_time, size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('6 min read', style: text.labelMedium),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialItem {
  const _EditorialItem(this.title, this.kicker, this.image);
  final String title;
  final String kicker;
  final String image;
}

const _stories = <_EditorialItem>[
  _EditorialItem(
    'A late-night ride through Bandalungwa',
    'STREET FOOD',
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&q=80',
  ),
  _EditorialItem(
    'The five plantain dishes every diaspora orders',
    'STAPLES',
    'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=800&q=80',
  ),
  _EditorialItem(
    'Where Brazzaville chefs eat on their day off',
    'PROFILES',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
  ),
];

class _EditorialCard extends StatelessWidget {
  const _EditorialCard({required this.item});
  final _EditorialItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(TastyRadii.xl)),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.network(item.image, fit: BoxFit.cover, errorBuilder: _imageFallback),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TastySpacing.stackMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.kicker,
                      style: text.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 6),
                  Text(item.title, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('4 min read', style: text.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _imageFallback(BuildContext _, Object __, StackTrace? ___) => Container(
      color: const Color(0xFFE5E2E1),
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF877462)),
    );
