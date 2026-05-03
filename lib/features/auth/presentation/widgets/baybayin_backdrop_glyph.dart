import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A single faded Baybayin glyph positioned within the hero backdrop.
class BaybayinBackdropGlyph extends StatelessWidget {
  const BaybayinBackdropGlyph({
    required this.char,
    required this.topFrac,
    required this.leftFrac,
    required this.containerWidth,
    required this.containerHeight,
    required this.fontSize,
    required this.rotDeg,
    required this.opacity,
    super.key,
  });

  final String char;
  final double topFrac;
  final double leftFrac;
  final double containerWidth;
  final double containerHeight;
  final double fontSize;
  final double rotDeg;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topFrac * containerHeight,
      left: leftFrac * containerWidth,
      child: Transform.rotate(
        angle: rotDeg * math.pi / 180,
        child: Text(
          char,
          style: TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: fontSize,
            color: Color.fromRGBO(255, 255, 255, opacity),
            height: 1.0,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
