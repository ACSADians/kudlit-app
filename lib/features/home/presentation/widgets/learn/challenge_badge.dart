import 'package:flutter/material.dart';

class ChallengeBadge extends StatelessWidget {
  const ChallengeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'CHALLENGE',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: cs.onPrimaryContainer,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
