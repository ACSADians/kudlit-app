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
  });

  final String selectedGlyph;
  final String selectedLabel;

  /// Committed strokes (pen-up events).
  final List<StrokeData> strokes;

  /// Points being drawn in the current in-progress stroke.
  final List<TimedPoint> currentStroke;

  /// Wall-clock timestamp when the current stroke began.
  final DateTime? strokeStartTime;

  bool get hasStrokes => strokes.isNotEmpty || currentStroke.isNotEmpty;

  StrokeRecordingIdle copyWith({
    String? selectedGlyph,
    String? selectedLabel,
    List<StrokeData>? strokes,
    List<TimedPoint>? currentStroke,
    DateTime? strokeStartTime,
    bool clearStrokeStart = false,
  }) {
    return StrokeRecordingIdle(
      selectedGlyph: selectedGlyph ?? this.selectedGlyph,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      strokes: strokes ?? this.strokes,
      currentStroke: currentStroke ?? this.currentStroke,
      strokeStartTime:
          clearStrokeStart ? null : (strokeStartTime ?? this.strokeStartTime),
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
  });

  final StrokePattern pattern;
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
