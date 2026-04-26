import 'dart:ui';

enum EventKind { buttyText, challenge, attempt, feedback }

class LessonEvent {
  const LessonEvent._({
    required this.kind,
    this.text,
    this.glyph,
    this.label,
    this.correct,
    this.strokes,
    this.detected,
  });

  factory LessonEvent.butty(String text) =>
      LessonEvent._(kind: EventKind.buttyText, text: text);

  factory LessonEvent.challenge({
    required String glyph,
    required String label,
  }) => LessonEvent._(kind: EventKind.challenge, glyph: glyph, label: label);

  factory LessonEvent.attempt({
    required List<List<Offset>> strokes,
    required String detected,
  }) => LessonEvent._(
    kind: EventKind.attempt,
    strokes: strokes,
    detected: detected,
  );

  factory LessonEvent.feedback({required bool correct, required String text}) =>
      LessonEvent._(kind: EventKind.feedback, correct: correct, text: text);

  final EventKind kind;
  final String? text;
  final String? glyph;
  final String? label;
  final bool? correct;
  final List<List<Offset>>? strokes;
  final String? detected;
}
