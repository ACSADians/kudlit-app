import 'package:flutter/material.dart';

class ChallengeHint extends StatelessWidget {
  const ChallengeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.touch_app_outlined,
            size: 14,
            color: cs.onSurface.withAlpha(120),
          ),
          const SizedBox(width: 6),
          Text(
            'Tap "Write in Baybayin" below to respond',
            style: TextStyle(
              fontSize: 11.5,
              color: cs.onSurface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
