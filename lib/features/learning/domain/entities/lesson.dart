import 'package:meta/meta.dart';

import 'lesson_step.dart';

@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<LessonStep> steps;
}
