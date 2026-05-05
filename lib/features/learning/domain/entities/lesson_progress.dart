import 'package:meta/meta.dart';

enum LessonStatus { notStarted, inProgress, completed }

@immutable
class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.completed,
    required this.score,
    required this.lastModified,
    this.completedAt,
  });

  final String lessonId;
  final int currentStepIndex;
  final int totalSteps;
  final bool completed;
  final int score;
  final DateTime lastModified;
  final DateTime? completedAt;

  LessonStatus get status {
    if (completed) return LessonStatus.completed;
    if (currentStepIndex > 0) return LessonStatus.inProgress;
    return LessonStatus.notStarted;
  }

  double get progressFraction =>
      totalSteps == 0 ? 0 : currentStepIndex / totalSteps;
}
