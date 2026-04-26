import 'package:flutter/material.dart';

class GlyphItem extends StatelessWidget {
  const GlyphItem({super.key, required this.glyph, required this.label});

  final String glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Text(
          glyph,
          style: TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 36,
            color: cs.onSurface,
            height: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: cs.onSurface.withAlpha(140),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
