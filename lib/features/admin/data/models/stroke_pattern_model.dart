import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';
import 'package:kudlit_ph/features/admin/domain/entities/timed_point.dart';

/// Data-layer model for [StrokePattern].
///
/// Handles serialisation to/from both Supabase row maps and the portable
/// JSON export format.
class StrokePatternModel extends StrokePattern {
  const StrokePatternModel({
    required super.id,
    required super.userId,
    required super.glyph,
    required super.label,
    required super.strokes,
    required super.canvasWidth,
    required super.canvasHeight,
    required super.deviceInfo,
    required super.createdAt,
  });

  // ─── Supabase row ─────────────────────────────────────────────────────────

  factory StrokePatternModel.fromRow(Map<String, dynamic> row) {
    final List<dynamic> rawStrokes =
        (row['strokes'] as List<dynamic>?) ?? <dynamic>[];

    return StrokePatternModel(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      glyph: row['glyph'] as String,
      label: row['label'] as String,
      strokes: rawStrokes
          .cast<Map<String, dynamic>>()
          .map(StrokeDataModel.fromJson)
          .toList(),
      canvasWidth: (row['canvas_width'] as num).toDouble(),
      canvasHeight: (row['canvas_height'] as num).toDouble(),
      deviceInfo:
          (row['device_info'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toRow() => <String, dynamic>{
    'user_id': userId,
    'glyph': glyph,
    'label': label,
    'strokes': strokes
        .map((StrokeData s) => StrokeDataModel.fromDomain(s).toJson())
        .toList(),
    'canvas_width': canvasWidth,
    'canvas_height': canvasHeight,
    'device_info': deviceInfo,
  };

  // ─── Portable JSON export ─────────────────────────────────────────────────

  /// Schema version for the exported file format.
  static const int _kSchemaVersion = 1;

  /// Builds the full export document for a single pattern.
  ///
  /// ```json
  /// {
  ///   "schema_version": 1,
  ///   "id": "...",
  ///   "user_id": "...",
  ///   "glyph": "ka",
  ///   "label": "Ka",
  ///   "canvas_width": 360.0,
  ///   "canvas_height": 480.0,
  ///   "device_info": { "platform": "android", ... },
  ///   "created_at": "2026-05-03T10:00:00.000Z",
  ///   "strokes": [
  ///     {
  ///       "points": [
  ///         { "x": 0.42, "y": 0.33, "t": 0 },
  ///         ...
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  Map<String, dynamic> toExportJson() => <String, dynamic>{
    'schema_version': _kSchemaVersion,
    'id': id,
    'user_id': userId,
    'glyph': glyph,
    'label': label,
    'canvas_width': canvasWidth,
    'canvas_height': canvasHeight,
    'device_info': deviceInfo,
    'created_at': createdAt.toUtc().toIso8601String(),
    'strokes': strokes
        .map((StrokeData s) => StrokeDataModel.fromDomain(s).toJson())
        .toList(),
  };

  factory StrokePatternModel.fromExportJson(Map<String, dynamic> json) {
    final List<dynamic> rawStrokes =
        (json['strokes'] as List<dynamic>?) ?? <dynamic>[];

    return StrokePatternModel(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      glyph: json['glyph'] as String,
      label: json['label'] as String,
      strokes: rawStrokes
          .cast<Map<String, dynamic>>()
          .map(StrokeDataModel.fromJson)
          .toList(),
      canvasWidth: (json['canvas_width'] as num).toDouble(),
      canvasHeight: (json['canvas_height'] as num).toDouble(),
      deviceInfo:
          (json['device_info'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Creates a [StrokePatternModel] from a domain entity.
  factory StrokePatternModel.fromDomain(StrokePattern p) => StrokePatternModel(
    id: p.id,
    userId: p.userId,
    glyph: p.glyph,
    label: p.label,
    strokes: p.strokes,
    canvasWidth: p.canvasWidth,
    canvasHeight: p.canvasHeight,
    deviceInfo: p.deviceInfo,
    createdAt: p.createdAt,
  );
}

/// Data-layer model for [StrokeData].
class StrokeDataModel extends StrokeData {
  const StrokeDataModel({required super.points});

  factory StrokeDataModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['points'] as List<dynamic>;
    return StrokeDataModel(
      points: raw
          .cast<Map<String, dynamic>>()
          .map(TimedPointModel.fromJson)
          .toList(),
    );
  }

  factory StrokeDataModel.fromDomain(StrokeData s) => StrokeDataModel(
    points: s.points
        .map((TimedPoint p) => TimedPointModel.fromDomain(p))
        .toList(),
  );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'points': points
        .map((TimedPoint p) => TimedPointModel.fromDomain(p).toJson())
        .toList(),
  };
}

/// Data-layer model for [TimedPoint].
class TimedPointModel extends TimedPoint {
  const TimedPointModel({required super.x, required super.y, required super.t});

  factory TimedPointModel.fromJson(Map<String, dynamic> json) =>
      TimedPointModel(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        t: (json['t'] as num).toInt(),
      );

  factory TimedPointModel.fromDomain(TimedPoint p) =>
      TimedPointModel(x: p.x, y: p.y, t: p.t);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y, 't': t};
}
