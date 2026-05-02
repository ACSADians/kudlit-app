// ignore: unnecessary_import — flutter_riverpod is needed for Ref resolution
import 'package:flutter/painting.dart' show Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/domain/usecases/load_lesson.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_repository_provider.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';

part 'lesson_controller.g.dart';

@riverpod
class LessonController extends _$LessonController {
  @override
  Future<LessonState?> build() async {
    return null;
  }

  Future<void> loadLesson(String lessonId) async {
    state = const AsyncLoading<LessonState?>();
    final LoadLesson useCase = ref.read(loadLessonUseCaseProvider);
    final Either<Failure, Lesson> result = await useCase(lessonId);
    state = result.fold(
      (Failure failure) => AsyncError<LessonState?>(
        _failureToException(failure),
        StackTrace.current,
      ),
      (Lesson lesson) => AsyncData<LessonState?>(
        LessonState(
          lesson: lesson,
          currentStepIndex: 0,
          attemptStatus: AttemptStatus.idle,
          buttyMessage: _introFor(lesson.steps.first),
          completed: false,
        ),
      ),
    );
  }

  /// Marks the state as [AttemptStatus.checking] immediately so the UI can
  /// show a loading indicator while async work (e.g. YOLO sketch inference)
  /// runs in the background.
  void startChecking() {
    final LessonState? current = state.value;
    if (current == null || current.completed) return;
    if (current.attemptStatus == AttemptStatus.checking) return;
    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: AttemptStatus.checking,
        buttyMessage: 'Checking your strokes...',
      ),
    );
  }

  /// Validates a YOLO-detected [label] for [LessonMode.draw] steps.
  ///
  /// Compares [label] (trimmed, lowercased) against [LessonStep.expected].
  void submitDetection(String label) {
    final LessonState? current = state.value;
    if (current == null || current.completed) return;
    final LessonStep step = current.currentStep;
    if (step.mode != LessonMode.draw) return;
    // YOLO joins multi-value class names with '_' (e.g. "e_i" for e/i).
    // Split and check whether any part matches the step's expected values.
    final List<String> parts = label
        .trim()
        .toLowerCase()
        .split('_')
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList();
    final bool isCorrect =
        parts.any((String p) => step.expected.contains(p));
    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: isCorrect ? AttemptStatus.correct : AttemptStatus.retry,
        buttyMessage: isCorrect
            ? (step.successFeedback ?? 'Correct!')
            : (step.hint ?? 'Not quite — keep practicing.'),
      ),
    );
  }

  /// Submits a drawing attempt. Stub: always treats as correct so the
  /// stage flow is fully wired. Replace with real similarity check later.
  Future<void> submitDraw(List<List<Offset>> strokes) async {
    final LessonState? current = state.value;
    if (current == null || current.completed) return;
    // Note: do NOT guard on AttemptStatus.checking here — the draw path
    // calls startChecking() before this, so the state is already checking.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final LessonStep step = current.currentStep;
    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: AttemptStatus.correct,
        buttyMessage: step.successFeedback ?? 'Correct.',
      ),
    );
  }

  /// Validates a typed answer for [LessonMode.freeInput] steps.
  Future<void> submitText(String value) async {
    final LessonState? current = state.value;
    if (current == null || current.completed) return;
    final LessonStep step = current.currentStep;
    if (step.mode != LessonMode.freeInput) return;

    final String normalized = value.trim().toLowerCase();
    final bool isCorrect = step.expected.contains(normalized);

    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: isCorrect ? AttemptStatus.correct : AttemptStatus.retry,
        buttyMessage: isCorrect
            ? (step.successFeedback ?? 'Correct.')
            : (step.hint ?? 'Not quite — try again.'),
      ),
    );
  }

  /// Used by [LessonMode.reference] steps: user taps "Got it" to continue.
  void acknowledge() {
    final LessonState? current = state.value;
    if (current == null) return;
    state = AsyncData<LessonState?>(
      current.copyWith(attemptStatus: AttemptStatus.correct),
    );
  }

  /// Advances to the next step or marks the lesson complete.
  void next() {
    final LessonState? current = state.value;
    if (current == null) return;
    final int nextIndex = current.currentStepIndex + 1;
    if (nextIndex >= current.lesson.steps.length) {
      state = AsyncData<LessonState?>(
        current.copyWith(
          completed: true,
          attemptStatus: AttemptStatus.idle,
          buttyMessage: 'Lesson complete. Magaling!',
        ),
      );
      return;
    }
    final LessonStep nextStep = current.lesson.steps[nextIndex];
    state = AsyncData<LessonState?>(
      current.copyWith(
        currentStepIndex: nextIndex,
        attemptStatus: AttemptStatus.idle,
        buttyMessage: _introFor(nextStep),
      ),
    );
  }

  void resetAttempt() {
    final LessonState? current = state.value;
    if (current == null) return;
    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: AttemptStatus.idle,
        buttyMessage: _introFor(current.currentStep),
      ),
    );
  }

  static String _introFor(LessonStep step) {
    return step.intro ?? step.prompt ?? step.narration ?? step.label;
  }

  static Exception _failureToException(Failure failure) {
    return failure.when(
      network: (String message) => Exception(message),
      invalidCredentials: () => Exception('Invalid credentials.'),
      userNotFound: () => Exception('User not found.'),
      emailAlreadyInUse: () => Exception('Email already in use.'),
      weakPassword: () => Exception('Weak password.'),
      tooManyRequests: () => Exception('Too many requests.'),
      sessionExpired: () => Exception('Session expired.'),
      passwordResetEmailSent: () => Exception('Password reset email sent.'),
      unknown: (String message) => Exception(message),
    );
  }
}
