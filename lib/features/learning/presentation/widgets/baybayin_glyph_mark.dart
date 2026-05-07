import 'package:flutter/material.dart';

class BaybayinGlyphMark extends StatelessWidget {
  const BaybayinGlyphMark({
    super.key,
    required this.glyph,
    required this.size,
    required this.color,
    this.boxSize,
  });

  final String glyph;
  final double size;
  final Color color;
  final double? boxSize;

  @override
  Widget build(BuildContext context) {
    final double dimension = boxSize ?? size * 1.6;
    return SizedBox.square(
      dimension: dimension,
      child: ClipRect(
        child: Center(
          child: Transform.translate(
            offset: Offset(_leftBearingOffset(glyph, size), 0),
            child: Text(
              glyph,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Baybayin Simple TAWBID',
                fontSize: size,
                height: 1,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _leftBearingOffset(String glyph, double size) {
    final String value = glyph.trim().toLowerCase();
    return value == 'e' || value == 'o' ? size * 0.52 : 0;
  }
}
