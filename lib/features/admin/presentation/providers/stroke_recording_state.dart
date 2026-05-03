import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';
import 'package:kudlit_ph/features/admin/domain/entities/timed_point.dart';

/// All Baybayin glyphs available for admin recording.
const List<({String glyph, String label})> kBaybayinGlyphs =
    <({String glyph, String label})>[
      (glyph: 'a', label: 'A'),
      (glyph: 'e', label: 'E / I'),
      (glyph: 'o', label: 'O / U'),
      (glyph: 'k', label: 'Ka'),
      (glyph: 'g', label: 'Ga'),
      (glyph: 'ng', label: 'Nga'),
      (glyph: 't', label: 'Ta'),
      (glyph: 'd', label: 'Da / Ra'),
      (glyph: 'n', label: 'Na'),
      (glyph: 'p', label: 'Pa'),
      (glyph: 'b', label: 'Ba'),
      (glyph: 'bi', label: 'Bi / Be'),
      (glyph: 'bu', label: 'Bu / Bo'),
      (glyph: 'm', label: 'Ma'),
      (glyph: 'y', label: 'Ya'),
      (glyph: 'l', label: 'La'),
      (glyph: 'w', label: 'Wa'),
      (glyph: 's', label: 'Sa'),
      (glyph: 'h', label: 'Ha'),
    ];

/// Notifier state for the admin stroke recording tool.
@immutable
sealed class StrokeRecordingState {
  const StrokeRecordingState();
}

/// Idle — ready to start a new recording.
@immutable
final class StrokeRecordingIdle extends StrokeRecordingState {
  const StrokeRecordingIdle({
    required this.selectedGlyph,
    required this.selectedLabel,
    this.strokes = const <StrokeData>[],
    this.currentStroke = const <TimedPoint>[],
    this.strokeStartTime,
    this.overlayImageBytes,
    this.strokeWidth = 4.0,
    this.sessionPatterns = const <StrokePattern>[],
  });

  final String selectedGlyph;
  final String selectedLabel;

  /// Committed strokes (pen-up events).
  final List<StrokeData> strokes;

  /// Points being drawn in the current in-progress stroke.
  final List<TimedPoint> currentStroke;

  /// Wall-clock timestamp when the current stroke began.
  final DateTime? strokeStartTime;

  /// Custom overlay image bytes (null → show Baybayin glyph text).
  final Uint8List? overlayImageBytes;

  /// Marker stroke width in logical pixels (2–16, default 4).
  final double strokeWidth;

  /// Patterns saved during this recording session.
  final List<StrokePattern> sessionPatterns;

  bool get hasStrokes => strokes.isNotEmpty || currentStroke.isNotEmpty;

  StrokeRecordingIdle copyWith({
    String? selectedGlyph,
    String? selectedLabel,
    List<StrokeData>? strokes,
    List<TimedPoint>? currentStroke,
    DateTime? strokeStartTime,
    bool clearStrokeStart = false,
    Uint8List? overlayImageBytes,
    bool clearOverlay = false,
    double? strokeWidth,
    List<StrokePattern>? sessionPatterns,
  }) {
    return StrokeRecordingIdle(
      selectedGlyph: selectedGlyph ?? this.selectedGlyph,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      strokes: strokes ?? this.strokes,
      currentStroke: currentStroke ?? this.currentStroke,
      strokeStartTime: clearStrokeStart
          ? null
          : (strokeStartTime ?? this.strokeStartTime),
      overlayImageBytes: clearOverlay
          ? null
          : (overlayImageBytes ?? this.overlayImageBytes),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      sessionPatterns: sessionPatterns ?? this.sessionPatterns,
    );
  }
}

/// Saving the recording to Supabase.
@immutable
final class StrokeRecordingSaving extends StrokeRecordingState {
  const StrokeRecordingSaving({
    required this.selectedGlyph,
    required this.selectedLabel,
  });

  final String selectedGlyph;
  final String selectedLabel;
}

/// Successfully saved.
@immutable
final class StrokeRecordingSaved extends StrokeRecordingState {
  const StrokeRecordingSaved({
    required this.pattern,
    this.sessionPatterns = const <StrokePattern>[],
  });

  final StrokePattern pattern;

  /// All patterns saved this session, including this one.
  final List<StrokePattern> sessionPatterns;
}

/// Error during save.
@immutable
final class StrokeRecordingError extends StrokeRecordingState {
  const StrokeRecordingError({
    required this.message,
    required this.selectedGlyph,
    required this.selectedLabel,
    required this.strokes,
  });

  final String message;
  final String selectedGlyph;
  final String selectedLabel;
  final List<StrokeData> strokes;
}
