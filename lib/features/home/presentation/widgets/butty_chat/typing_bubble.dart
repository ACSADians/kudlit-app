import 'package:flutter/material.dart';

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/brand/ButtyRead.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              '\u00b7\u00b7\u00b7',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withAlpha(140),
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
