import 'package:meta/meta.dart';

/// A single timed touch point on the drawing canvas.
///
/// [x] and [y] are normalised to the canvas size (range 0–1).
/// [t] is milliseconds elapsed since the first point of the current stroke.
@immutable
class TimedPoint {
  const TimedPoint({required this.x, required this.y, required this.t});

  final double x;
  final double y;
  final int t; // ms since stroke start

  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y, 't': t};

  factory TimedPoint.fromJson(Map<String, dynamic> json) => TimedPoint(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    t: (json['t'] as num).toInt(),
  );
}
