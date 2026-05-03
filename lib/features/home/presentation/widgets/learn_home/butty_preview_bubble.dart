import 'package:flutter/material.dart';

class ButtyPreviewBubble extends StatelessWidget {
  const ButtyPreviewBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(13),
          bottomLeft: Radius.circular(13),
          bottomRight: Radius.circular(13),
        ),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        'Kumusta! I\'m here to help. Ask me anything about Baybayin,'
        ' or just talk to me about the script.',
        style: TextStyle(
          fontSize: 13,
          color: cs.onSurface.withAlpha(190),
          height: 1.45,
        ),
      ),
    );
  }
}
