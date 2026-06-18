import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';

/// `add_payment_method` — add a real payment method to the wallet. Supports
/// the local rails (Orange Money, Airtel Money, card, cash). The new method
/// is appended to [AppState.paymentMethods] and shows up on the wallet screen.
class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

enum _MethodKind { orangeMoney, airtelMoney, card, cash }

extension on _MethodKind {
  String get label => switch (this) {
        _MethodKind.orangeMoney => 'Orange Money',
        _MethodKind.airtelMoney => 'Airtel Money',
        _MethodKind.card => 'Card',
        _MethodKind.cash => 'Cash on delivery',
      };

  IconData get icon => switch (this) {
        _MethodKind.orangeMoney => Icons.smartphone,
        _MethodKind.airtelMoney => Icons.smartphone,
        _MethodKind.card => Icons.credit_card,
        _MethodKind.cash => Icons.payments,
      };

  bool get needsNumber => this != _MethodKind.cash;
  bool get isCard => this == _MethodKind.card;
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  _MethodKind _kind = _MethodKind.orangeMoney;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  void _save() {
    if (_kind.needsNumber && !_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    final raw = _number.text.trim();
    final String sub;
    if (!_kind.needsNumber) {
      sub = 'Pay the driver';
    } else if (_kind.isCard) {
      final last4 = raw.length >= 4 ? raw.substring(raw.length - 4) : raw;
      sub = '•••• $last4';
    } else {
      // Mask the middle of the mobile-money number.
      sub = raw.length >= 4 ? '${raw.substring(0, raw.length - 4)} *** **${raw.substring(raw.length - 2)}' : raw;
    }
    AppState.instance.addPaymentMethod(
      PaymentMethod(icon: _kind.icon, label: _kind.label, sub: sub),
    );
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_kind.label} added'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Add payment method')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(TastySpacing.marginPage),
          children: [
            Text('Method type', style: text.titleSmall),
            const SizedBox(height: TastySpacing.stackSm),
            for (final kind in _MethodKind.values)
              RadioListTile<_MethodKind>(
                value: kind,
                groupValue: _kind,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _kind = v!);
                },
                secondary: Icon(kind.icon, color: scheme.primary),
                title: Text(kind.label),
                contentPadding: EdgeInsets.zero,
              ),
            if (_kind.needsNumber) ...[
              const SizedBox(height: TastySpacing.stackMd),
              TextFormField(
                controller: _number,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: _kind.isCard ? 'Card number' : 'Mobile money number',
                  prefixIcon: Icon(_kind.icon),
                ),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (_kind.isCard) {
                    return s.length < 12 ? 'Enter a valid card number' : null;
                  }
                  return s.length < 8 ? 'Enter a valid number' : null;
                },
              ),
            ],
            const SizedBox(height: TastySpacing.sectionGap),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.add),
                label: const Text('Add method'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
