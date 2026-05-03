import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';

class LessonStepModel extends LessonStep {
  const LessonStepModel({
    required super.id,
    required super.mode,
    required super.label,
    required super.glyph,
    super.glyphImage,
    super.intro,
    super.prompt,
    super.narration,
    super.hint,
    super.successFeedback,
    super.buttyTip,
    super.expected,
    super.hideGlyph,
  });

  factory LessonStepModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawExpected =
        (json['expected'] as List<dynamic>?) ?? const <dynamic>[];
    return LessonStepModel(
      id: json['id'] as String,
      mode: LessonMode.fromJson(json['mode'] as String),
      label: json['label'] as String,
      glyph: json['glyph'] as String,
      glyphImage: json['glyphImage'] as String?,
      intro: json['intro'] as String?,
      prompt: json['prompt'] as String?,
      narration: json['narration'] as String?,
      hint: json['hint'] as String?,
      successFeedback: json['successFeedback'] as String?,
      buttyTip: json['buttyTip'] as String?,
      expected: rawExpected
          .map((dynamic e) => (e as String).trim().toLowerCase())
          .toList(growable: false),
      hideGlyph: (json['hideGlyph'] as bool?) ?? false,
    );
  }
}
