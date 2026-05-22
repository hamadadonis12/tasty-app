import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `driver_dashboard_fleet_one` — driver home: today's earnings, online
/// toggle, weekly chart, recent trips, big "Go Online" action.
class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
            ),
          ),
        ),
        title: Text('TastyLife', style: text.titleLarge?.copyWith(color: scheme.primary)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Today's earnings hero
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xxlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Today's Earnings", style: text.titleSmall),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TastyColors.successContainer,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, size: 14, color: TastyColors.onSuccessContainer),
                          const SizedBox(width: 4),
                          Text('+12% vs yesterday',
                              style: text.labelSmall?.copyWith(
                                color: TastyColors.onSuccessContainer,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('\$184.50',
                    style: text.displayLarge?.copyWith(
                      color: scheme.primary,
                      fontSize: 56,
                    )),
                Row(
                  children: [
                    Text('Daily goal progress', style: text.bodySmall),
                    const Spacer(),
                    Text('92% of \$200',
                        style: text.labelMedium?.copyWith(color: scheme.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: TastyRadii.fullRadius,
                  child: LinearProgressIndicator(
                    value: 0.92,
                    minHeight: 8,
                    backgroundColor: scheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          // Online toggle button
          Container(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            decoration: BoxDecoration(
              color: TastyColors.successContainer,
              borderRadius: TastyRadii.xlRadius,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: TastyColors.success,
                  child: Icon(Icons.bolt, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You're online",
                          style: text.titleSmall?.copyWith(color: TastyColors.onSuccessContainer)),
                      Text('Receiving offers · Auto-pause in 1h 20m',
                          style: text.bodySmall?.copyWith(color: TastyColors.onSuccessContainer)),
                    ],
                  ),
                ),
                Switch(value: true, onChanged: (_) {}),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          // This week card with mini bar chart
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This Week', style: text.titleSmall),
                          Text('Nov 12 – Nov 18', style: text.bodySmall),
                        ],
                      ),
                    ),
                    Text('\$842.20', style: text.titleLarge?.copyWith(color: scheme.primary)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final (i, h) in [(0, 0.4), (1, 0.55), (2, 0.7), (3, 0.95), (4, 0.6), (5, 0.5), (6, 0.3)])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              height: 60 * h,
                              decoration: BoxDecoration(
                                color: i == 3 ? scheme.primary : scheme.primaryContainer.withValues(alpha: 0.4),
                                borderRadius: TastyRadii.smRadius,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((d) => Expanded(child: Center(child: Text(d, style: text.labelSmall))))
                      .toList(),
                )
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          // Recent trips
          Row(children: [Text('Recent Trips', style: text.titleSmall), const Spacer(), TextButton(onPressed: () {}, child: const Text('View All'))]),
          const SizedBox(height: 6),
          for (final t in const [
            ('Today · 10:42', 'Maison Kinshasa → Gombe', '+\$8.50'),
            ('Today · 09:14', 'Le Grill → Limete', '+\$12.20'),
            ('Yesterday', 'Sushi Lounge → Kasa-Vubu', '+\$9.80'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: TastyRadii.lgRadius,
                boxShadow: TastyShadows.ambient,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.pedal_bike, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(t.$2, style: text.titleSmall), Text(t.$1, style: text.bodySmall)],
                    ),
                  ),
                  Text(t.$3,
                      style: text.titleSmall?.copyWith(color: TastyColors.success, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        onPressed: () {},
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Cash Out'),
      ),
    );
  }
}
