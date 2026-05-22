import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `AppChat` from the v2 design — customer ↔ driver chat thread.
///
/// Header with driver avatar + live ETA + call button → order strip → message
/// bubbles (driver left, customer right in primary orange) → quick replies
/// → live-location share card → composer input.
///
/// Content is DRC-localized: Jean Kabila driver, +243, Maison Kinshasa, FC.
class ChatWithDriverScreen extends StatelessWidget {
  const ChatWithDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DriverHeader(scheme: scheme, text: text),
            _OrderStrip(scheme: scheme, text: text),
            Expanded(child: _MessageList(scheme: scheme, text: text)),
            _Composer(scheme: scheme, text: text),
          ],
        ),
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
          const CircleAvatar(
            radius: 19,
            backgroundColor: TastyColors.brandInk,
            child: Text('JK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jean · your rider', style: text.titleSmall),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: TastyColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('4 min away',
                        style: text.labelSmall?.copyWith(
                          color: TastyColors.success, fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: HapticFeedback.lightImpact,
            style: IconButton.styleFrom(
              backgroundColor: TastyColors.brandOrange,
              foregroundColor: TastyColors.brandInk,
            ),
            icon: const Icon(Icons.call, size: 18),
          ),
        ],
      ),
    );
  }
}

class _OrderStrip extends StatelessWidget {
  const _OrderStrip({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: TastyColors.brandOrangeTint,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: Colors.white, borderRadius: TastyRadii.smRadius),
            child: Icon(Icons.shopping_bag, color: TastyColors.brandOrangeDeep, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Order #TL-47821 · Maison Kinshasa · 18 500 FC',
                style: text.labelMedium?.copyWith(color: TastyColors.brandInk)),
          ),
          Text('View →',
              style: text.labelMedium?.copyWith(
                color: TastyColors.brandOrangeDeep,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: TastyRadii.fullRadius,
            ),
            child: Text('TODAY · 14:22',
                style: text.labelSmall?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                )),
          ),
        ),
        const SizedBox(height: 12),
        // Quick replies pill set
        _QuickReplies(scheme: scheme, text: text),
        const SizedBox(height: 10),
        _DriverBubble(
          message: 'Hi — I\'m 4 min away. Should I buzz the intercom or leave at door?',
          time: 'Jean · 14:22',
        ),
        const SizedBox(height: 8),
        _CustomerBubble(
          message: 'Please buzz apartment 14. I\'ll come down.',
          time: '14:23 · read',
        ),
        const SizedBox(height: 8),
        _DriverBubble(message: 'Got it, see you in 3 ✌️', time: 'Jean · 14:24'),
        const SizedBox(height: 12),
        const _LiveLocationCard(),
      ],
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;
  static const _replies = [
    'I\'m at the gate',
    'Leave at door',
    'Call me when close',
    'Thanks! 🙏',
  ];
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: TastyRadii.mdRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUICK REPLIES',
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                )),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                for (final r in _replies)
                  GestureDetector(
                    onTap: HapticFeedback.lightImpact,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: TastyRadii.fullRadius,
                      ),
                      child: Text(r,
                          style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverBubble extends StatelessWidget {
  const _DriverBubble({required this.message, required this.time});
  final String message;
  final String time;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(TastyRadii.lg),
              topRight: Radius.circular(TastyRadii.lg),
              bottomRight: Radius.circular(TastyRadii.lg),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: text.bodyMedium),
              const SizedBox(height: 4),
              Text(time, style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerBubble extends StatelessWidget {
  const _CustomerBubble({required this.message, required this.time});
  final String message;
  final String time;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: TastyColors.brandOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(TastyRadii.lg),
              topRight: Radius.circular(TastyRadii.lg),
              bottomLeft: Radius.circular(TastyRadii.lg),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message, style: text.bodyMedium?.copyWith(color: TastyColors.brandInk)),
              const SizedBox(height: 4),
              Text(time,
                  style: text.labelSmall?.copyWith(
                    color: TastyColors.brandInk.withValues(alpha: 0.65),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveLocationCard extends StatelessWidget {
  const _LiveLocationCard();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: TastyRadii.lgRadius,
        ),
        child: ClipRRect(
          borderRadius: TastyRadii.smRadius,
          child: AspectRatio(
            aspectRatio: 240 / 90,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: scheme.surfaceContainerLow),
                ),
                // Soft "streets" lines
                Positioned.fill(
                  child: CustomPaint(painter: _StreetsPainter()),
                ),
                // Driver pin
                const Center(
                  child: _DriverPin(),
                ),
                Positioned(
                  left: 6, bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TastyColors.brandInk,
                      borderRadius: TastyRadii.smRadius,
                    ),
                    child: Text('LIVE · 3 min',
                        style: text.labelSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.0,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverPin extends StatelessWidget {
  const _DriverPin();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: TastyColors.brandOrange,
        shape: BoxShape.circle,
        border: Border.all(color: TastyColors.brandInk, width: 2),
      ),
    );
  }
}

class _StreetsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14;
    canvas.drawLine(
      Offset(-10, size.height / 2),
      Offset(size.width + 10, size.height / 2),
      paint,
    );
    canvas.drawLine(
      const Offset(60, -10),
      Offset(60, size.height + 10),
      paint..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Composer extends StatelessWidget {
  const _Composer({required this.scheme, required this.text});
  final ColorScheme scheme;
  final TextTheme text;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: TastyRadii.mdRadius,
              ),
              child: Icon(Icons.add, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  borderRadius: TastyRadii.mdRadius,
                ),
                child: Text('Type a message…',
                    style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: TastyColors.brandOrange,
                borderRadius: TastyRadii.mdRadius,
              ),
              child: Icon(Icons.send, color: TastyColors.brandInk, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
