import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `rate_your_experience` — emoji-driven food + driver rating, tip presets,
/// optional note, single Submit CTA.
class RateExperienceScreen extends StatefulWidget {
  const RateExperienceScreen({super.key});
  @override
  State<RateExperienceScreen> createState() => _RateExperienceScreenState();
}

class _RateExperienceScreenState extends State<RateExperienceScreen> {
  int _food = 5;
  int _driver = 4;
  int _tipIdx = 1;

  static const _tips = ['\$2', '\$5', '\$10', 'Custom'];
  static const _foodLabels = ['Awful', 'Bad', 'OK', 'Good', 'Excellent'];
  static const _foodEmojis = ['😞', '😐', '🙂', '😋', '🤩'];
  static const _driverLabels = ['Poor', 'Below', 'OK', 'Good', 'Great'];
  static const _driverEmojis = ['😡', '😕', '🙂', '😊', '😍'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Feedback'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          _Card(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: TastyRadii.mdRadius,
                  child: SizedBox(
                    width: 48, height: 48,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=200&q=80',
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
                      Text('Le Bistrot Moderne', style: text.titleSmall),
                      Text('Order #KE-8924 · Delivered 15 min ago',
                          style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          _Card(
            child: Column(
              children: [
                Text('How was the food?', style: text.titleMedium),
                Text('Rate your culinary experience',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Text(_foodEmojis[_food - 1], style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 6),
                _Stars(value: _food, onChange: (v) => setState(() => _food = v)),
                const SizedBox(height: 8),
                Text(_foodLabels[_food - 1],
                    style: text.titleSmall?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          _Card(
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jean Kabila', style: text.titleSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: TastyRadii.fullRadius,
                          ),
                          child: Text('Gold Partner',
                              style: text.labelSmall?.copyWith(color: scheme.primary)),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Rate your delivery experience', style: text.bodyMedium),
                const SizedBox(height: 10),
                Text(_driverEmojis[_driver - 1], style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                _Stars(value: _driver, onChange: (v) => setState(() => _driver = v)),
                const SizedBox(height: 6),
                Text(_driverLabels[_driver - 1], style: text.labelMedium),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Add a tip for Jean', style: text.titleSmall),
                    const Spacer(),
                    Icon(Icons.volunteer_activism, color: scheme.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(_tips.length, (i) {
                    final sel = _tipIdx == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _tipIdx = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? scheme.primary : scheme.surfaceContainerLow,
                            borderRadius: TastyRadii.lgRadius,
                          ),
                          child: Text(_tips[i],
                              style: text.titleSmall?.copyWith(
                                color: sel ? scheme.onPrimary : scheme.onSurface,
                              )),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text('100% of your tip goes to the driver.',
                    style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Leave a note about your order or delivery experience…',
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Submit Feedback'),
            onPressed: () {
              HapticFeedback.heavyImpact();
              // Land back on the home shell at the root of the navigator stack.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(TastySpacing.stackMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.xlRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: child,
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.onChange});
  final int value;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          onPressed: () => onChange(i + 1),
          icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: scheme.primary, size: 30),
        );
      }),
    );
  }
}
