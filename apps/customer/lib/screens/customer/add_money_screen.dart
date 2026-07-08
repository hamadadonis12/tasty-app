import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';

/// `add_money` — full-screen wallet top-up.
///
/// Reached from the Wallet card's "Top Up" action. The customer enters a
/// custom amount or taps a preset, sees their remaining monthly limit, and
/// confirms. Top-ups flow through [AppState.topUp] so the balance, ledger
/// and monthly limit all update live.
class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key, this.method = 'Orange Money'});

  /// Payment method the top-up is billed to (preselected in the Wallet).
  final String method;

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  /// Quick-select presets, laid out as the 2×2 grid in the reference.
  static const _presets = <int>[5000, 10000, 25000, 50000];

  final _controller = TextEditingController();
  int? _amount;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    // Keep only digits so "10 000" / "10,000" still parse.
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() => _amount = digits.isEmpty ? null : int.tryParse(digits));
  }

  void _selectPreset(int value) {
    HapticFeedback.selectionClick();
    _controller.text = value.toString();
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() => _amount = value);
  }

  void _submit() {
    final amount = _amount;
    final messenger = ScaffoldMessenger.of(context);
    if (amount == null || amount <= 0) return;

    final remaining = AppState.instance.monthlyTopUpRemainingFc;
    if (amount > remaining) {
      HapticFeedback.heavyImpact();
      messenger.showSnackBar(SnackBar(
        content: Text('Exceeds your monthly limit (${formatFc(remaining)} left)'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final ok = AppState.instance.topUp(amount, method: widget.method);
    if (!ok) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(
      content: Text('Added ${formatFc(amount)} via ${widget.method}'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final valid = _amount != null && _amount! > 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TastySpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add money',
                  style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: TastySpacing.sectionGap),

              // ── Amount field ──
              TextField(
                controller: _controller,
                onChanged: _onChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: text.titleMedium,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  filled: true,
                  fillColor: scheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Text('FC',
                        textAlign: TextAlign.right,
                        style: text.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: _fieldBorder(scheme.outlineVariant),
                  enabledBorder: _fieldBorder(scheme.outlineVariant),
                  focusedBorder: _fieldBorder(scheme.primary, width: 2),
                ),
              ),
              const SizedBox(height: TastySpacing.sectionGap),

              // ── Preset grid (2×2) ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 2.6,
                children: [
                  for (final p in _presets)
                    _PresetTile(
                      label: formatFc(p).replaceAll(' FC', ''),
                      selected: _amount == p,
                      onTap: () => _selectPreset(p),
                    ),
                ],
              ),

              const Spacer(),

              // ── Monthly remaining limit ──
              ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) => Row(
                  children: [
                    Text('Monthly Remaining Limit',
                        style: text.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    const Spacer(),
                    Text(formatFc(AppState.instance.monthlyTopUpRemainingFc),
                        style: text.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: TastySpacing.stackMd),

              // ── Add money CTA ──
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: valid ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: TastyColors.brandOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        TastyColors.brandOrange.withValues(alpha: 0.42),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text('ADD MONEY',
                      style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      )),
                ),
              ),
              const SizedBox(height: TastySpacing.stackMd),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1.4}) =>
      OutlineInputBorder(
        borderRadius: TastyRadii.lgRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: TastyRadii.lgRadius,
      child: InkWell(
        borderRadius: TastyRadii.lgRadius,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: TastyRadii.lgRadius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1.4,
            ),
          ),
          child: Text(label,
              style: text.titleLarge?.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              )),
        ),
      ),
    );
  }
}
