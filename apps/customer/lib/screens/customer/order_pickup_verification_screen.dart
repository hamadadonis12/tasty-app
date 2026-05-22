import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'proof_of_delivery_screen.dart';

/// `order_pickup_verification` — driver shows the 4-digit handoff PIN at
/// the restaurant. Restaurant types it in, or driver enters customer's
/// PIN at drop-off.
class OrderPickupVerificationScreen extends StatelessWidget {
  const OrderPickupVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const pin = ['8', '4', '2', '7'];
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Pickup Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        child: Column(
          children: [
            const SizedBox(height: TastySpacing.sectionGap),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: TastyShadows.glow,
              ),
              child: Icon(Icons.lock_outline, color: scheme.onPrimaryContainer, size: 32),
            ),
            const SizedBox(height: TastySpacing.stackLg),
            Text('Show this PIN to the restaurant',
                textAlign: TextAlign.center, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'They\'ll enter it on their tablet to release the order.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final d in pin)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 64, height: 80,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: TastyRadii.xlRadius,
                      boxShadow: TastyShadows.ambient,
                      border: Border.all(color: scheme.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(d, style: text.displaySmall?.copyWith(color: scheme.primary)),
                  ),
              ],
            ),
            const SizedBox(height: TastySpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(TastySpacing.stackMd),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: TastyRadii.lgRadius,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('This PIN refreshes every 5 minutes.',
                        style: text.bodySmall),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProofOfDeliveryScreen()),
                );
              },
              child: const Text("I've handed off the order"),
            ),
            const SizedBox(height: TastySpacing.stackSm),
            TextButton(onPressed: () {}, child: const Text('Something went wrong')),
          ],
        ),
      ),
    );
  }
}
