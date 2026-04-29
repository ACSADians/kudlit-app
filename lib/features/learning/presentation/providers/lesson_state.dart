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
  });

  final Lesson lesson;
  final int currentStepIndex;
  final AttemptStatus attemptStatus;
  final String buttyMessage;
  final bool completed;

  LessonStep get currentStep => lesson.steps[currentStepIndex];

  double get progress =>
      lesson.steps.isEmpty ? 0 : (currentStepIndex + 1) / lesson.steps.length;

  LessonState copyWith({
    int? currentStepIndex,
    AttemptStatus? attemptStatus,
    String? buttyMessage,
    bool? completed,
  }) {
    return LessonState(
      lesson: lesson,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      attemptStatus: attemptStatus ?? this.attemptStatus,
      buttyMessage: buttyMessage ?? this.buttyMessage,
      completed: completed ?? this.completed,
    );
  }
}
