import 'package:flutter/material.dart';

class PadHeader extends StatelessWidget {
  const PadHeader({
    super.key,
    required this.targetGlyph,
    required this.targetLabel,
  });

  final String targetGlyph;
  final String targetLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Write: $targetLabel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Draw on the canvas below',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
            child: Center(
              child: Text(
                targetGlyph,
                style: TextStyle(
                  fontFamily: 'Baybayin Simple TAWBID',
                  fontSize: 28,
                  color: cs.onPrimaryContainer,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
