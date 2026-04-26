import 'package:flutter/material.dart';

import 'online_dot.dart';

class GemmaChip extends StatelessWidget {
  const GemmaChip({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const OnlineDot(),
          const SizedBox(width: 5),
          Text(
            'Gemma 4',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
