import 'package:meta/meta.dart';

/// A single normalised touch point within a stroke.
///
/// [x] and [y] are in the range 0–1 relative to the recording canvas.
/// [t] is milliseconds elapsed since the first point of the stroke.
@immutable
class GlyphPoint {
  const GlyphPoint({required this.x, required this.y, required this.t});

  final double x;
  final double y;
  final int t;

  factory GlyphPoint.fromJson(Map<String, dynamic> json) => GlyphPoint(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    t: (json['t'] as num).toInt(),
  );
}

/// One continuous pen-down → pen-up stroke, used for stroke-order playback.
@immutable
class GlyphStroke {
  const GlyphStroke({required this.points});

  final List<GlyphPoint> points;

  factory GlyphStroke.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['points'] as List<dynamic>;
    return GlyphStroke(
      points: raw
          .cast<Map<String, dynamic>>()
          .map(GlyphPoint.fromJson)
          .toList(growable: false),
    );
  }
}

/// The full stroke-order recording for a single glyph, including the
/// aspect ratio of the canvas it was recorded on.
///
/// [aspectRatio] = canvasWidth / canvasHeight from [stroke_patterns].
/// Used by [StrokeOrderSheet] to preserve the proportions of the recording.
@immutable
class StrokeOrderData {
  const StrokeOrderData({required this.strokes, required this.aspectRatio});

  final List<GlyphStroke> strokes;

  /// width ÷ height of the recording canvas (always > 0).
  final double aspectRatio;

  bool get isEmpty => strokes.isEmpty;
}
