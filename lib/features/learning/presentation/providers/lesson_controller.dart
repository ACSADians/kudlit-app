// ignore: unnecessary_import — flutter_riverpod is needed for Ref resolution
import 'package:flutter/painting.dart' show Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/domain/usecases/load_lesson.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_repository_provider.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';

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

  /// Submits a drawing attempt and streams Gemma evaluation feedback.
  Future<void> submitDraw(List<List<Offset>> strokes) async {
    final LessonState? current = state.value;
    if (current == null || current.completed) return;
    if (current.attemptStatus == AttemptStatus.checking) return;

    state = AsyncData<LessonState?>(
      current.copyWith(
        attemptStatus: AttemptStatus.checking,
        buttyMessage: 'Analyzing your strokes...',
      ),
    );

    final LessonStep step = current.currentStep;
    
    try {
      final Stream<String> responseStream = ref
          .read(aiInferenceNotifierProvider.notifier)
          .generateResponse(
            <ChatMessage>[
              ChatMessage(
                text: 'Evaluate my drawing for ${step.label}',
                isUser: true,
                timestamp: DateTime.now(),
              )
            ],
            systemInstruction: GemmaPrompts.sketchpadEvaluator(step.label),
          );

      final StringBuffer buffer = StringBuffer();
      
      // Update state to correct immediately so they can proceed,
      // but stream the feedback from Gemma into buttyMessage.
      state = AsyncData<LessonState?>(
        current.copyWith(
          attemptStatus: AttemptStatus.correct,
          buttyMessage: '',
        ),
      );

      await for (final String chunk in responseStream) {
        buffer.write(chunk);
        final LessonState? updated = state.valueOrNull;
        if (updated != null && updated.currentStepIndex == current.currentStepIndex) {
          state = AsyncData<LessonState?>(
            updated.copyWith(buttyMessage: buffer.toString()),
          );
        }
      }
    } catch (e) {
      final LessonState? updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncData<LessonState?>(
          updated.copyWith(
            attemptStatus: AttemptStatus.correct,
            buttyMessage: step.successFeedback ?? 'Correct.',
          ),
        );
      }
    }
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
