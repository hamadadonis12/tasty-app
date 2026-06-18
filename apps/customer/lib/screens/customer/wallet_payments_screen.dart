import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import 'add_payment_method_screen.dart';
import 'send_credit_screen.dart';
import 'transaction_history_screen.dart';

/// `wallet_payments` — TastyLife balance + payment methods + recent
/// transactions list. Localized to Kinshasa: Orange Money, Airtel Money,
/// card, and cash on delivery. Balance, methods and transactions are all
/// backed by [AppState], so top-ups, transfers and new methods are live.
class WalletPaymentsScreen extends StatefulWidget {
  const WalletPaymentsScreen({super.key});
  @override
  State<WalletPaymentsScreen> createState() => _WalletPaymentsScreenState();
}

class _WalletPaymentsScreenState extends State<WalletPaymentsScreen> {
  int _selectedMethod = 0;

  void _push(Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showTopUpSheet() {
    HapticFeedback.lightImpact();
    final methods = AppState.instance.paymentMethods;
    final method = methods[_selectedMethod.clamp(0, methods.length - 1)].label;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TastyRadii.xxl)),
      ),
      builder: (_) => _TopUpSheet(method: method),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _push(const TransactionHistoryScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          final methods = s.paymentMethods;
          if (_selectedMethod >= methods.length) _selectedMethod = 0;
          final recent = s.transactions.take(4).toList();
          return ListView(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            children: [
              Container(
                padding: const EdgeInsets.all(TastySpacing.gutterCard),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.primaryContainer],
                  ),
                  borderRadius: TastyRadii.xxlRadius,
                  boxShadow: TastyShadows.glow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TASTY CREDIT',
                        style: text.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.6,
                        )),
                    const SizedBox(height: 8),
                    Text(formatFc(s.balanceFc),
                        style: text.displaySmall?.copyWith(color: Colors.white)),
                    Text('≈ \$${s.balanceUsd.toStringAsFixed(2)}',
                        style: text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: TastySpacing.stackMd),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Top Up'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: scheme.primary,
                            ),
                            onPressed: _showTopUpSheet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: const Text('Send', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                            ),
                            onPressed: () => _push(const SendCreditScreen()),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Text('Payment methods', style: text.titleSmall),
              const SizedBox(height: TastySpacing.stackSm),
              for (var i = 0; i < methods.length; i++)
                _Method(
                  icon: methods[i].icon,
                  label: methods[i].label,
                  sub: methods[i].sub,
                  selected: i == _selectedMethod,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMethod = i);
                  },
                ),
              TextButton.icon(
                onPressed: () => _push(const AddPaymentMethodScreen()),
                icon: const Icon(Icons.add),
                label: const Text('Add new method'),
              ),
              const SizedBox(height: TastySpacing.sectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent transactions', style: text.titleSmall),
                  TextButton(
                    onPressed: () => _push(const TransactionHistoryScreen()),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: TastySpacing.stackSm),
              for (final t in recent)
                _Tx(
                  label: t.label,
                  amount: formatFc(t.amountFc, signed: true),
                  sub: t.sub,
                  positive: t.positive,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Method extends StatelessWidget {
  const _Method({
    required this.icon, required this.label, required this.sub,
    required this.selected, required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: TastyRadii.lgRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.titleSmall),
                    Text(sub, style: text.bodySmall),
                  ],
                ),
              ),
              // Visible selection indicator that matches the surrounding
              // outline; replaces the deprecated `Radio.groupValue` API.
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 11, height: 11,
                        decoration: BoxDecoration(
                          color: scheme.primary, shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tx extends StatelessWidget {
  const _Tx({required this.label, required this.amount, required this.sub, required this.positive});
  final String label;
  final String amount;
  final String sub;
  final bool positive;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: positive
                ? TastyColors.successContainer
                : scheme.surfaceContainer,
            child: Icon(
              positive ? Icons.arrow_downward : Icons.arrow_upward,
              color: positive ? TastyColors.onSuccessContainer : scheme.onSurfaceVariant,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: text.titleSmall), Text(sub, style: text.bodySmall)],
            ),
          ),
          Text(amount,
              style: text.titleSmall?.copyWith(
                color: positive ? TastyColors.success : scheme.onSurface,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({required this.method});
  final String method;
  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  static const _amounts = [5000, 10000, 25000, 50000, 100000];
  int _amount = 25000;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TastySpacing.marginPage,
        TastySpacing.stackMd,
        TastySpacing.marginPage,
        MediaQuery.viewInsetsOf(context).bottom + TastySpacing.stackLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 14),
          Text('Top up via ${widget.method}', style: text.titleLarge),
          const SizedBox(height: 4),
          Text('Choose an amount or enter a custom value.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: TastySpacing.stackMd),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (final a in _amounts)
                ChoiceChip(
                  label: Text('$a FC'),
                  selected: a == _amount,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _amount = a);
                  },
                ),
            ],
          ),
          const SizedBox(height: TastySpacing.stackLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                AppState.instance.topUp(_amount, method: widget.method);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Topped up ${formatFc(_amount)} via ${widget.method}'),
                  behavior: SnackBarBehavior.floating,
                ));
              },
              style: FilledButton.styleFrom(
                backgroundColor: TastyColors.brandInk,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Top up $_amount FC'),
            ),
          ),
        ],
      ),
    );
  }
}
