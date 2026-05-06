import 'package:flutter/material.dart';

class ReferenceGlyphCard extends StatelessWidget {
  const ReferenceGlyphCard({
    super.key,
    required this.glyph,
    required this.label,
    this.glyphImage,
    this.compact = false,
    this.hideGlyph = false,
  });

  final String glyph;
  final String label;

  /// Optional URL for a custom glyph image. When set, this is shown instead
  /// of rendering [glyph] with the Baybayin font.
  final String? glyphImage;
  final bool compact;

  /// When true, the glyph character is replaced with a "?" placeholder.
  /// Used for recall/challenge steps where the learner draws from memory.
  final bool hideGlyph;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double size = compact ? 58 : 112;
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 28 : 48,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: cs.onPrimaryContainer,
                  letterSpacing: 0,
                ),
              ),
            )
          else ...<Widget>[
            if (glyphImage != null)
              Image.network(
                glyphImage!,
                height: size,
                width: size,
                fit: BoxFit.contain,
                color: cs.onPrimaryContainer,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, _, _) => Text(
                  glyph,
                  style: TextStyle(
                    fontFamily: 'Baybayin Simple TAWBID',
                    fontSize: size,
                    height: 1,
                    color: cs.onPrimaryContainer,
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
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
