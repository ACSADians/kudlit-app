import 'package:flutter/material.dart';

class ChallengePinBar extends StatelessWidget {
  const ChallengePinBar({super.key, required this.glyph, required this.label});

  final String glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: cs.outline),
          bottom: BorderSide(color: cs.outline),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            'Write this now',
            style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(120)),
          ),
          const SizedBox(width: 10),
          Text(
            glyph,
            style: TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: 26,
              color: cs.onSurface,
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.draw_outlined,
            size: 14,
            color: cs.onSurface.withAlpha(80),
          ),
          const SizedBox(width: 4),
          Text(
            'tap below',
            style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(80)),
          ),
        ],
      ),
    );
  }
}
