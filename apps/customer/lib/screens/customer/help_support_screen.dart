import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/cart_controller.dart';

/// `help_support` — search field, top FAQs, "Contact us" CTAs (chat,
/// call, email), and "Order issue?" deep link.
///
/// Every interactive element produces feedback so the customer can
/// "test like it's live": search filters the FAQ list inline, channel
/// tiles open a sheet with the real contact, FAQ tiles expand to the
/// answer, and "Get help" opens an order-issue triage sheet.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> get _filteredFaqs {
    if (_query.isEmpty) return _faqs;
    return _faqs.where((f) {
      return f.$1.toLowerCase().contains(_query) || f.$2.toLowerCase().contains(_query);
    }).toList();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void _openChannel(String label, String value, IconData icon, {bool copyable = true}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final text = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Icon(icon, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: text.titleLarge)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: TastyRadii.lgRadius,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(value,
                          style: text.titleSmall?.copyWith(
                            fontFamily: 'JetBrains Mono',
                            color: scheme.primary,
                            letterSpacing: 0.5,
                          )),
                    ),
                    if (copyable)
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        tooltip: 'Copy',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: value));
                          Navigator.pop(ctx);
                          _toast('$label copied to clipboard');
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label == 'Live chat'
                    ? 'Our agents respond in under 90 seconds on average. They speak French, English, and Lingala.'
                    : 'Available 24/7. Calls from DRC mobile networks are free.',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openOrderIssueSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final text = Theme.of(ctx).textTheme;
        const issues = <(String, IconData)>[
          ('Item is missing', Icons.indeterminate_check_box_outlined),
          ('Wrong item delivered', Icons.swap_horiz),
          ('Quality issue', Icons.thumb_down_alt_outlined),
          ('Order never arrived', Icons.cancel_outlined),
          ('Driver was unprofessional', Icons.person_off),
          ('Something else', Icons.help_outline),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("What's the issue?", style: text.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Pick a reason. Eligible refunds are processed in under 1 hour.',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final issue in issues)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      child: Icon(issue.$2, color: scheme.primary, size: 18),
                    ),
                    title: Text(issue.$1, style: text.titleSmall),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      _toast('Reported "${issue.$1}" — support will follow up in <1h');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final lastOrder = CartController.instance.pastOrders.isNotEmpty
        ? CartController.instance.pastOrders.first
        : null;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(TastySpacing.marginPage),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(TastySpacing.gutterCard),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.18),
              borderRadius: TastyRadii.xxlRadius,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.support_agent, color: scheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("We're here, day & night.", style: text.titleSmall),
                      Text('Average reply time: 90 seconds',
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.gutterCard),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search the help center…',
              prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Contact us', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Row(
            children: [
              Expanded(
                child: _Channel(
                  icon: Icons.chat_bubble,
                  label: 'Live chat',
                  sub: 'Avg 90s',
                  onTap: () => _openChannel(
                    'Live chat',
                    'chat.tastylife.cd',
                    Icons.chat_bubble,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Channel(
                  icon: Icons.call,
                  label: 'Call us',
                  sub: '+243 …',
                  onTap: () => _openChannel(
                    'Call us',
                    '+243 89 700 5500',
                    Icons.call,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Channel(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  sub: 'support@…',
                  onTap: () => _openChannel(
                    'Email',
                    'support@tastylife.cd',
                    Icons.mail_outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text('Order issue?', style: text.titleSmall),
          const SizedBox(height: TastySpacing.stackSm),
          Container(
            padding: const EdgeInsets.all(TastySpacing.stackMd),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: TastyRadii.xlRadius,
              boxShadow: TastyShadows.ambient,
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lastOrder?.restaurantName ?? 'No recent orders',
                          style: text.titleSmall),
                      Text(
                        lastOrder == null
                            ? 'Place an order first to report issues.'
                            : '${lastOrder.itemsDescription.split(',').length} items · '
                                '\$${lastOrder.total.toStringAsFixed(2)} · Delivered',
                        style: text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: lastOrder == null ? null : _openOrderIssueSheet,
                  child: const Text('Get help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: TastySpacing.sectionGap),
          Text(
            _query.isEmpty
                ? 'Top FAQs'
                : '${_filteredFaqs.length} match${_filteredFaqs.length == 1 ? '' : 'es'} for "$_query"',
            style: text.titleSmall,
          ),
          const SizedBox(height: TastySpacing.stackSm),
          if (_filteredFaqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No FAQ matched. Try contacting support above.',
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            for (final q in _filteredFaqs)
              ExpansionTile(
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                title: Text(q.$1, style: text.titleSmall),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.$2, style: text.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Was this helpful?',
                                style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                              tooltip: 'Helpful',
                              onPressed: () => _toast('Thanks for the feedback!'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_down_alt_outlined, size: 16),
                              tooltip: 'Not helpful',
                              onPressed: () => _toast("We'll improve this answer."),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

const _faqs = <(String, String)>[
  ('How do I track my order?', 'Open Orders → Live Order Tracking. You\'ll see the driver pin and ETA in real time.'),
  ('What if my order is late?', 'Tap "Get help" on the order. We\'ll credit you on the spot if it\'s more than 15 min past ETA.'),
  ('Can I pay cash?', 'Yes, choose "Cash on delivery" at checkout. Drivers carry change up to 50 000 FC.'),
  ('How do I become a Gold member?', 'Order 10 times in a month or refer 3 friends.'),
  ('Which mobile-money services work?', 'Airtel Money, Orange Money, and M-Pesa DRC are all supported at checkout.'),
  ('Can I schedule an order for later?', 'Yes — pick "Schedule" instead of ASAP on the checkout screen. Slots are 30-min windows up to 7 days ahead.'),
  ('How do refunds work?', 'Eligible refunds are credited within 1 hour. They appear in your wallet and can be applied to your next order or withdrawn to mobile money.'),
];

class _Channel extends StatelessWidget {
  const _Channel({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
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
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.xlRadius,
            boxShadow: TastyShadows.ambient,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: scheme.primary, size: 18),
              ),
              const SizedBox(height: 6),
              Text(label, style: text.labelMedium),
              Text(sub, style: text.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
