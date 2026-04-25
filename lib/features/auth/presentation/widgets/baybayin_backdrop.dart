import 'package:flutter/widgets.dart';

import 'baybayin_backdrop_glyph.dart';

/// Faded Baybayin glyphs scattered behind the login hero.
/// Uses the `Baybayin Simple TAWBID` font which maps Latin syllables
/// (e.g. "ka", "ba") to their Baybayin character via OpenType substitution.
class BaybayinBackdrop extends StatelessWidget {
  const BaybayinBackdrop({super.key});

  static const List<_Spec> _specs = <_Spec>[
    _Spec(
      char: 'ka',
      topFrac: 0.04,
      leftFrac: -0.04,
      size: 140,
      rotDeg: -8,
      opacity: 0.08,
    ),
    _Spec(
      char: 'ba',
      topFrac: 0.30,
      leftFrac: 0.72,
      size: 100,
      rotDeg: 12,
      opacity: 0.07,
    ),
    _Spec(
      char: 'la',
      topFrac: 0.14,
      leftFrac: 0.52,
      size: 80,
      rotDeg: -4,
      opacity: 0.09,
    ),
    _Spec(
      char: 'na',
      topFrac: 0.48,
      leftFrac: -0.06,
      size: 110,
      rotDeg: 6,
      opacity: 0.06,
    ),
    _Spec(
      char: 'ma',
      topFrac: 0.58,
      leftFrac: 0.82,
      size: 70,
      rotDeg: -10,
      opacity: 0.07,
    ),
    _Spec(
      char: 'pa',
      topFrac: 0.70,
      leftFrac: 0.20,
      size: 90,
      rotDeg: 8,
      opacity: 0.05,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          return Stack(
            children: <Widget>[
              for (final _Spec s in _specs)
                BaybayinBackdropGlyph(
                  char: s.char,
                  topFrac: s.topFrac,
                  leftFrac: s.leftFrac,
                  containerWidth: w,
                  containerHeight: h,
                  fontSize: s.size,
                  rotDeg: s.rotDeg,
                  opacity: s.opacity,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Spec {
  const _Spec({
    required this.char,
    required this.topFrac,
    required this.leftFrac,
    required this.size,
    required this.rotDeg,
    required this.opacity,
  });

  final String char;
  final double topFrac;
  final double leftFrac;
  final double size;
  final double rotDeg;
  final double opacity;
}
