import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';

enum AttemptStatus { idle, checking, correct, retry }

@immutable
class LessonState {
  const LessonState({
    required this.lesson,
    required this.currentStepIndex,
    required this.attemptStatus,
    required this.buttyMessage,
    required this.completed,
    this.firstAttemptPasses = 0,
  });

  final Lesson lesson;
  final int currentStepIndex;
  final AttemptStatus attemptStatus;
  final String buttyMessage;
  final bool completed;

  /// Number of steps the user answered correctly on the very first attempt.
  /// Used to compute the lesson score (firstAttemptPasses / totalSteps * 100).
  final int firstAttemptPasses;

  LessonStep get currentStep => lesson.steps[currentStepIndex];

  double get progress =>
      lesson.steps.isEmpty ? 0 : (currentStepIndex + 1) / lesson.steps.length;

  int get score {
    final int total = lesson.steps.length;
    if (total == 0) return 0;
    return ((firstAttemptPasses / total) * 100).round().clamp(0, 100);
  }

  LessonState copyWith({
    int? currentStepIndex,
    AttemptStatus? attemptStatus,
    String? buttyMessage,
    bool? completed,
    int? firstAttemptPasses,
  }) {
    return LessonState(
      lesson: lesson,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      attemptStatus: attemptStatus ?? this.attemptStatus,
      buttyMessage: buttyMessage ?? this.buttyMessage,
      completed: completed ?? this.completed,
      firstAttemptPasses: firstAttemptPasses ?? this.firstAttemptPasses,
    );
  }
}
