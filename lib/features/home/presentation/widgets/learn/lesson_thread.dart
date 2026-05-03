import 'package:flutter/material.dart';

import 'butty_lesson_card.dart';
import 'feedback_card.dart';
import 'glyph_challenge_card.dart';
import 'lesson_event.dart';
import 'user_attempt_card.dart';

class LessonThread extends StatelessWidget {
  const LessonThread({super.key, required this.events, required this.scroll});

  final List<LessonEvent> events;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: events.length,
      itemBuilder: (_, int i) {
        final LessonEvent e = events[i];
        return switch (e.kind) {
          EventKind.buttyText => ButtyLessonCard(text: e.text!),
          EventKind.challenge => GlyphChallengeCard(
            glyph: e.glyph!,
            label: e.label!,
          ),
          EventKind.attempt => UserAttemptCard(
            strokes: e.strokes!,
            detected: e.detected!,
          ),
          EventKind.feedback => FeedbackCard(
            correct: e.correct!,
            text: e.text!,
          ),
        };
      },
    );
  }
}
