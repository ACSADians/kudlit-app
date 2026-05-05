import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/utils/safe_ai_output.dart';

class ButtyBubble extends StatelessWidget {
  const ButtyBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String displayText = cleanAssistantOutput(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
                displayText,
                style: TextStyle(
                  fontSize: 13.5,
                  color: cs.onSurface.withAlpha(220),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
