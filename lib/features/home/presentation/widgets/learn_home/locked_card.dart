import 'package:flutter/material.dart';

import 'locked_card_text.dart';

class LockedCard extends StatelessWidget {
  const LockedCard({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final int index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LockedCardText(
              index: index,
              title: title,
              subtitle: subtitle,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Soon',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withAlpha(100),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
