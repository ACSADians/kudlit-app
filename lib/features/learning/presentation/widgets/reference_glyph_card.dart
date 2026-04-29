import 'package:flutter/material.dart';

class ReferenceGlyphCard extends StatelessWidget {
  const ReferenceGlyphCard({
    super.key,
    required this.glyph,
    required this.label,
    this.compact = false,
    this.hideGlyph = false,
  });

  final String glyph;
  final String label;
  final bool compact;

  /// When true, the glyph character is replaced with a "?" placeholder.
  /// Used for recall/challenge steps where the learner draws from memory.
  final bool hideGlyph;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double size = compact ? 64 : 120;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 10 : 18,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hideGlyph)
            SizedBox(
              height: size * 1.1,
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: size,
                    height: 1,
                    fontWeight: FontWeight.w300,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.35),
                  ),
                ),
              ),
            )
          else
            Text(
              glyph,
              style: TextStyle(
                fontFamily: 'Baybayin Simple TAWBID',
                fontSize: size,
                height: 1,
                color: cs.onPrimaryContainer,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
