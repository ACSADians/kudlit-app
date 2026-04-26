import 'package:flutter/material.dart';

import 'challenge_hint.dart';
import 'challenge_top.dart';

class GlyphChallengeCard extends StatelessWidget {
  const GlyphChallengeCard({
    super.key,
    required this.glyph,
    required this.label,
  });

  final String glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          children: <Widget>[
            ChallengeTop(glyph: glyph, label: label),
            const ChallengeHint(),
          ],
        ),
      ),
    );
  }
}
