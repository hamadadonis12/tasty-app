import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';

/// `send_credit` — transfer TastyLife credit to another user by phone. Real:
/// validates the amount against the wallet balance, deducts on success, and
/// records a transaction. Insufficient funds is handled gracefully.
class SendCreditScreen extends StatefulWidget {
  const SendCreditScreen({super.key});

  @override
  State<SendCreditScreen> createState() => _SendCreditScreenState();
}

class _SendCreditScreenState extends State<SendCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipient = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _recipient.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    final fc = int.parse(_amount.text.trim());
    final ok = AppState.instance.sendCredit(fc: fc, recipient: _recipient.text.trim());
    if (!ok) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Not enough balance for this transfer'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Sent ${formatFc(fc)} to ${_recipient.text.trim()}'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Send credit')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final balance = AppState.instance.balanceFc;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(TastySpacing.marginPage),
              children: [
                Container(
                  padding: const EdgeInsets.all(TastySpacing.gutterCard),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.18),
                    borderRadius: TastyRadii.xlRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: scheme.primary),
                      const SizedBox(width: 12),
                      Text('Available balance', style: text.bodyMedium),
                      const Spacer(),
                      Text(formatFc(balance),
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: TastySpacing.sectionGap),
                TextFormField(
                  controller: _recipient,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Recipient's phone",
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: '+243 …',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 8) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: TastySpacing.stackMd),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Amount (FC)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) return 'Enter an amount';
                    if (n > balance) return 'Amount exceeds your balance';
                    return null;
                  },
                ),
                const SizedBox(height: TastySpacing.stackMd),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final a in const [2000, 5000, 10000, 20000])
                      ActionChip(
                        label: Text('$a FC'),
                        onPressed: () => setState(() => _amount.text = '$a'),
                      ),
                  ],
                ),
                const SizedBox(height: TastySpacing.sectionGap),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Send credit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
