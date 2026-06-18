import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';
import 'rate_experience_screen.dart';

/// `proof_of_delivery` — driver-side capture: photo, signature, or
/// "left with security" + delivery note + Complete Delivery.
class ProofOfDeliveryScreen extends StatefulWidget {
  const ProofOfDeliveryScreen({super.key});
  @override
  State<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends State<ProofOfDeliveryScreen> {
  int _mode = 0; // 0 photo, 1 signature, 2 security

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Proof of Delivery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Address chip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: TastyRadii.xlRadius,
                boxShadow: TastyShadows.ambient,
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: scheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ORDER #KE-8924',
                            style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
                        Text('124 Avenue de la Justice, Apt 4B, Gombe',
                            style: text.titleSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TastySpacing.gutterCard),
            // Camera viewport
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: TastyRadii.xlRadius,
                  boxShadow: TastyShadows.ambient,
                ),
                child: ClipRRect(
                  borderRadius: TastyRadii.xlRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1607853202273-797f1c22a38e?w=900&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: TastyRadii.fullRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('Photo Mode Active',
                                  style: text.labelSmall?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 18,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 4),
                              boxShadow: TastyShadows.glow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: TastySpacing.gutterCard),
            Row(
              children: [
                Expanded(child: _ModeCard(icon: Icons.draw, label: 'Customer Signature', selected: _mode == 1, onTap: () => setState(() => _mode = 1))),
                const SizedBox(width: 10),
                Expanded(child: _ModeCard(icon: Icons.security, label: 'Left with Security', selected: _mode == 2, onTap: () => setState(() => _mode = 2))),
              ],
            ),
            const SizedBox(height: TastySpacing.gutterCard),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add delivery notes (optional)…',
              ),
            ),
            const SizedBox(height: TastySpacing.gutterCard),
            FilledButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete Delivery'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Delivery completed → graduate the order to history.
                CartController.instance.markActiveOrderReceived();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RateExperienceScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.15) : scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.xlRadius,
      child: InkWell(
        borderRadius: TastyRadii.xlRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(TastySpacing.stackMd),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: text.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
