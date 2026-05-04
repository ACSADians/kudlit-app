import 'package:meta/meta.dart';

import 'glyph_stroke.dart';
import 'lesson_mode.dart';

@immutable
class LessonStep {
  const LessonStep({
    required this.id,
    required this.mode,
    required this.label,
    required this.glyph,
    this.glyphImage,
    this.intro,
    this.prompt,
    this.narration,
    this.hint,
    this.successFeedback,
    this.buttyTip,
    this.expected = const <String>[],
    this.hideGlyph = false,
    this.strokeOrder,
  });

  final String id;
  final LessonMode mode;
  final String label;
  final String glyph;

  /// Optional URL for a custom glyph image. When set, the UI shows this
  /// image instead of rendering [glyph] with the Baybayin font.
  final String? glyphImage;
  final String? intro;
  final String? prompt;
  final String? narration;
  final String? hint;
  final String? successFeedback;
  final String? buttyTip;

  /// Accepted answers for [LessonMode.freeInput]. Compared
  /// case-insensitively after trimming.
  final List<String> expected;

  /// When true, the Baybayin glyph is hidden — used for recall/challenge
  /// steps where the learner must produce the glyph from memory.
  final bool hideGlyph;

  /// Recorded stroke order for this glyph, fetched from [stroke_patterns]
  /// by [glyph]. Null when no recording exists yet.
  final StrokeOrderData? strokeOrder;
}
