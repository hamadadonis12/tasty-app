import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

/// `legal` — Terms of Service, Privacy Policy and licenses. Real, scrollable
/// content (no "coming soon"), grouped into expandable sections.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Legal')),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          Text('TastyLife · Kinshasa', style: text.titleMedium),
          const SizedBox(height: 4),
          Text('Effective 1 June 2026 · Version 2.4.0',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: TastySpacing.sectionGap),
          ..._sections.map((s) => _LegalSection(title: s.$1, body: s.$2)),
          const SizedBox(height: TastySpacing.stackLg),
          Center(
            child: TextButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'TastyLife',
                applicationVersion: '2.4.0',
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Open-source licenses'),
            ),
          ),
        ],
      ),
    );
  }

  static const List<(String, String)> _sections = [
    (
      'Terms of Service',
      'By using TastyLife you agree to order food and groceries through our '
          'marketplace for personal use. Orders are fulfilled by independent '
          'restaurants and delivered by independent couriers. Prices include '
          'applicable taxes; delivery and service fees are shown before you pay.',
    ),
    (
      'Privacy Policy',
      'We collect your name, contact details, delivery address and order '
          'history to operate the service. Location is used only while an order '
          'is active, to match you with nearby restaurants and couriers. We do '
          'not sell your personal data. You can request export or deletion of '
          'your data from Help & Support at any time.',
    ),
    (
      'Payments & Refunds',
      'Payments are processed via Orange Money, Airtel Money, card, or cash on '
          'delivery. If an order is cancelled before the restaurant accepts it, '
          'you are refunded in full to your TastyLife wallet. Quality issues are '
          'reviewed case by case within 48 hours.',
    ),
    (
      'Courier & Restaurant Conduct',
      'Couriers and restaurants are bound by our community standards covering '
          'hygiene, safety and respectful conduct. Report any concern through the '
          'in-app chat or Help & Support and our Kinshasa operations team will '
          'follow up.',
    ),
  ];
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: TastySpacing.stackMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: TastyRadii.lgRadius,
        boxShadow: TastyShadows.ambient,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title, style: text.titleSmall),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(body, style: text.bodyMedium?.copyWith(height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
