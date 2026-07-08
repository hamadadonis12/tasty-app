import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/restaurant.dart';
import 'restaurant_detail_screen.dart';

/// `find_my_craving` — HungerStation-style mood-driven AI discovery
/// (PRD US-C18 / FR-C-017). The customer picks one or more mood tags,
/// hits "Find my craving", and the screen returns 3-5 personalised
/// recommendations with a one-sentence rationale.
///
/// The recommendation logic here is deterministic stub: it filters the
/// [RestaurantCatalog] by tag and explains the match. A production build
/// would route this through the Claude API.
class FindMyCravingScreen extends StatefulWidget {
  const FindMyCravingScreen({super.key});
  @override
  State<FindMyCravingScreen> createState() => _FindMyCravingScreenState();
}

class _FindMyCravingScreenState extends State<FindMyCravingScreen> {
  final Set<String> _selected = <String>{};
  List<_Recommendation> _recs = const [];
  bool _searched = false;

  static const _moods = <(String, String)>[
    ('🌶️', 'Spicy'),
    ('🥗', 'Healthy'),
    ('🍔', 'Comfort'),
    ('💸', 'Cheap'),
    ('💍', 'Date night'),
    ('☕', 'Café'),
    ('🍕', 'Italian'),
    ('🥘', 'Local DRC'),
    ('🍣', 'Asian'),
    ('🌙', 'Late night'),
  ];

  void _findCraving() {
    HapticFeedback.mediumImpact();
    final selectedLower = _selected.map((s) => s.toLowerCase()).toList();
    final out = <_Recommendation>[];
    for (final r in RestaurantCatalog.all) {
      final hay = '${r.cuisine} ${r.tags.join(' ')} ${r.district}'.toLowerCase();
      final matches = selectedLower.where(hay.contains).toList();
      if (matches.isNotEmpty || _selected.isEmpty) {
        out.add(_Recommendation(
          restaurant: r,
          reason: _selected.isEmpty
              ? 'Top rated in ${r.district} · ${r.etaRange}'
              : 'Matches your ${matches.join(", ")} mood · ${r.etaRange}',
        ));
      }
    }
    out.sort((a, b) => b.restaurant.rating.compareTo(a.restaurant.rating));
    setState(() {
      _searched = true;
      _recs = out.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Find My Craving'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer,
                  scheme.primaryContainer.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.glow,
            ),
            child: Row(
              children: [
                const Text('🪄', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Not sure what to eat?',
                          style: text.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        'Pick a few moods and our AI will surface what fits you tonight.',
                        style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          Text("What's your mood?", style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in _moods)
                FilterChip(
                  label: Text('${m.$1} ${m.$2}'),
                  selected: _selected.contains(m.$2),
                  onSelected: (v) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (v) {
                        _selected.add(m.$2);
                      } else {
                        _selected.remove(m.$2);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          FilledButton.icon(
            onPressed: _findCraving,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Find my craving'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),

          if (_searched) ...[
            Text(
              _recs.isEmpty ? 'No matches yet' : 'Hand-picked for you',
              style: text.titleMedium,
            ),
            const SizedBox(height: TastySpacing.stackSm),
            if (_recs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Try selecting different moods.',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              for (final rec in _recs) ...[
                _RecCard(rec: rec),
                const SizedBox(height: 10),
              ],
          ],
        ],
      ),
    );
  }
}

class _Recommendation {
  const _Recommendation({required this.restaurant, required this.reason});
  final Restaurant restaurant;
  final String reason;
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec});
  final _Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurant: rec.restaurant),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: TastyRadii.lgRadius,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.network(
                    rec.restaurant.heroImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: scheme.surfaceContainer),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(rec.restaurant.name,
                              style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Icon(Icons.star_rounded, size: 16, color: scheme.primary),
                        const SizedBox(width: 2),
                        Text('${rec.restaurant.rating}',
                            style: text.labelMedium?.copyWith(color: scheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(rec.restaurant.cuisine,
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Text(
                        rec.reason,
                        style: text.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
