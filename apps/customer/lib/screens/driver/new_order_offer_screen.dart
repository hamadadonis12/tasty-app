import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `new_order_offer` — incoming order with countdown timer, earnings,
/// pickup + dropoff, slide-to-accept.
class NewOrderOfferScreen extends StatelessWidget {
  const NewOrderOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header: timer + dismiss
            Padding(
              padding: const EdgeInsets.fromLTRB(TastySpacing.marginPage, 8, TastySpacing.marginPage, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: TastyRadii.fullRadius,
                      boxShadow: TastyShadows.ambient,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text('00:45', style: text.titleSmall?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.maybePop(context)),
                ],
              ),
            ),
            // Map placeholder
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(TastySpacing.marginPage),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.surfaceContainerLow,
                      scheme.primaryContainer.withValues(alpha: 0.18),
                    ],
                  ),
                  borderRadius: TastyRadii.xlRadius,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(300, 200),
                        painter: _DashedLinePainter(color: scheme.primary),
                      ),
                    ),
                    Positioned(
                      left: 80,
                      top: 60,
                      child: _MapPin(label: 'Pickup', color: scheme.primary),
                    ),
                    Positioned(
                      right: 50,
                      bottom: 80,
                      child: _MapPin(label: 'Dropoff', color: TastyColors.success, icon: Icons.flag),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom sheet
            Container(
              padding: const EdgeInsets.all(TastySpacing.gutterCard),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
                boxShadow: TastyShadows.sheet,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                    ),
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GUARANTEED EARNINGS',
                                style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
                            Text('\$8.50',
                                style: text.displaySmall?.copyWith(color: scheme.primary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('EST. TIME', style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
                          Text('22 min', style: text.titleLarge),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: TastySpacing.stackMd),
                  _StopRow(
                    color: scheme.primary,
                    icon: Icons.restaurant,
                    title: 'Kinshasa Bites',
                    sub: '14 Avenue de la Justice, Gombe · 2.4 mi away',
                  ),
                  const SizedBox(height: 10),
                  _StopRow(
                    color: TastyColors.success,
                    icon: Icons.person,
                    title: 'Dropoff',
                    sub: '87 Boulevard du 30 Juin · 4.1 mi total trip',
                  ),
                  const SizedBox(height: TastySpacing.stackLg),
                  // Slide to accept
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: TastyRadii.fullRadius,
                      boxShadow: TastyShadows.glow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: scheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward, color: scheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Text('Swipe to Accept',
                            style: text.titleMedium?.copyWith(color: scheme.onPrimary)),
                        const Spacer(),
                        Icon(Icons.double_arrow, color: scheme.onPrimary.withValues(alpha: 0.6)),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Decline Offer')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label, required this.color, this.icon = Icons.restaurant});
  final String label;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: TastyShadows.ambient),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        Container(width: 2, height: 8, color: color),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.color, required this.icon, required this.title, required this.sub});
  final Color color;
  final IconData icon;
  final String title;
  final String sub;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleSmall),
              Text(sub, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(20, 100)..quadraticBezierTo(size.width / 2, 20, size.width - 20, 140);
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      var dist = 0.0;
      while (dist < m.length) {
        final next = dist + dashWidth;
        canvas.drawPath(m.extractPath(dist, next), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
