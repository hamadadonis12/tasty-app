import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `shift_streak_manager` — driver shift planning + streak rewards.
/// Big streak number, weekly grid, available quests.
class ShiftStreakManagerScreen extends StatelessWidget {
  const ShiftStreakManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Shifts & Streaks')),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Streak hero
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primaryContainer],
              ),
              borderRadius: TastyRadii.xxlRadius,
              boxShadow: TastyShadows.glow,
            ),
            child: Row(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
                ),
                const SizedBox(width: TastySpacing.stackMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current streak',
                          style: text.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                      Text('14 days',
                          style: text.displaySmall?.copyWith(color: Colors.white)),
                      Text('Unlock +30 FC/trip at 20 days',
                          style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('This Week', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Container(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final done = i < 4;
                final today = i == 4;
                final label = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
                return Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: done
                            ? scheme.primary
                            : today
                                ? scheme.primaryContainer.withValues(alpha: 0.3)
                                : scheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                        border: today ? Border.all(color: scheme.primary, width: 2) : null,
                      ),
                      child: done
                          ? Icon(Icons.check, color: scheme.onPrimary, size: 18)
                          : Center(child: Text(label, style: text.labelSmall)),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: text.labelSmall?.copyWith(
                          color: today ? scheme.primary : scheme.onSurfaceVariant,
                          fontWeight: today ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Active Quests', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          _Quest(
            icon: Icons.bolt,
            title: '5 trips during peak hours',
            sub: '3 / 5 · ends 22:00',
            progress: 0.6,
            reward: '+\$5',
          ),
          _Quest(
            icon: Icons.weekend,
            title: 'Saturday night marathon',
            sub: '0 / 10 trips · this Sat',
            progress: 0.0,
            reward: '+\$25',
          ),
          _Quest(
            icon: Icons.star_rounded,
            title: 'Keep 4.9 rating',
            sub: '4.9 · streak active',
            progress: 1.0,
            reward: '+5%',
          ),
        ],
      ),
    );
  }
}

class _Quest extends StatelessWidget {
  const _Quest({required this.icon, required this.title, required this.sub, required this.progress, required this.reward});
  final IconData icon;
  final String title;
  final String sub;
  final double progress;
  final String reward;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final done = progress >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (done ? TastyColors.success : scheme.primary).withValues(alpha: 0.12),
            child: Icon(icon, color: done ? TastyColors.success : scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                Text(sub, style: text.bodySmall),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: TastyRadii.fullRadius,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation(
                      done ? TastyColors.success : scheme.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(reward,
              style: text.titleSmall?.copyWith(
                color: done ? TastyColors.success : scheme.primary,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}
