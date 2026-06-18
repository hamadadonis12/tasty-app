import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../state/app_state.dart';

/// `transaction_history` — full wallet ledger, newest first, driven by
/// [AppState.transactions] so top-ups and transfers appear here live.
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(leading: const BackButton(), title: const Text('Transaction history')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final txs = AppState.instance.transactions;
          if (txs.isEmpty) {
            return Center(
              child: Text('No transactions yet',
                  style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(TastySpacing.marginPage),
            itemCount: txs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final t = txs[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          t.positive ? TastyColors.successContainer : scheme.surfaceContainer,
                      child: Icon(
                        t.icon,
                        color: t.positive ? TastyColors.onSuccessContainer : scheme.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.label, style: text.titleSmall),
                          Text(t.sub, style: text.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      formatFc(t.amountFc, signed: true),
                      style: text.titleSmall?.copyWith(
                        color: t.positive ? TastyColors.success : scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
