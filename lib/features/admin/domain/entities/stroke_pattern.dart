import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/admin/domain/entities/timed_point.dart';

/// One continuous pen-down → pen-up stroke, with timed sample points.
@immutable
class StrokeData {
  const StrokeData({required this.points});

  final List<TimedPoint> points;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'points': points.map((TimedPoint p) => p.toJson()).toList(),
  };

  factory StrokeData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['points'] as List<dynamic>;
    return StrokeData(
      points: raw
          .cast<Map<String, dynamic>>()
          .map(TimedPoint.fromJson)
          .toList(),
    );
  }
}

/// A complete admin-recorded stroke pattern for a single Baybayin glyph.
@immutable
class StrokePattern {
  const StrokePattern({
    required this.id,
    required this.userId,
    required this.glyph,
    required this.label,
    required this.strokes,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.deviceInfo,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// Short identifier matching [LessonStep.glyph], e.g. `'a'`, `'ka'`.
  final String glyph;

  /// Human-readable label, e.g. `'A'`, `'Ka'`.
  final String label;

  /// Ordered list of strokes that make up the character.
  final List<StrokeData> strokes;

  /// Reference canvas dimensions used to record the strokes.
  final double canvasWidth;
  final double canvasHeight;

  /// Platform / device metadata for scaling analysis.
  final Map<String, dynamic> deviceInfo;

  final DateTime createdAt;
}
