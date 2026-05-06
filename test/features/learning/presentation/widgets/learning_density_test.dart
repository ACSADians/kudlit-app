import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/quiz_provider.dart';
import 'package:kudlit_ph/features/learning/presentation/screens/quiz_screen.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/butty_coach_panel.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/lesson_progress_bar.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/lesson_top_bar.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/modes/reference_mode_body.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/quiz_result_card.dart';

void main() {
  testWidgets('lesson detail fits a short landscape viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(593, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                LessonTopBar(
                  title: 'Baybayin Vowels',
                  subtitle: 'Three vowels, three shapes.',
                  onClose: () {},
                ),
                const LessonProgressBar(
                  progress: 0.25,
                  label: 'Step 1 of 7 - E / I',
                ),
                Expanded(
                  child: ReferenceModeBody(
                    step: _referenceStep,
                    attemptStatus: AttemptStatus.idle,
                  ),
                ),
                ButtyCoachPanel(
                  message: 'Study the shape, then continue when ready.',
                  attemptStatus: AttemptStatus.idle,
                  completed: false,
                  actionLabel: 'Got it',
                  showPrimaryAction: true,
                  onAvatarTap: () {},
                  onContinue: () {},
                  onAskHelp: () {},
                  onRetry: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Got it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quiz answering screen fits a narrow phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 593));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [quizProvider.overrideWith(_FakeQuizNotifier.new)],
        child: const MaterialApp(home: QuizScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Question 1 of 1'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quiz result actions keep compact tap targets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuizResultCard(
            score: 1,
            total: 1,
            onRetry: () {},
            onDone: () {},
          ),
        ),
      ),
    );

    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const LessonStep _referenceStep = LessonStep(
  id: 'ref-ei',
  mode: LessonMode.reference,
  label: 'E / I',
  glyph: 'e',
  narration:
      'This mirrored curve shares one Baybayin glyph for both E and I sounds.',
);

const LessonStep _quizStep = LessonStep(
  id: 'spell-a',
  mode: LessonMode.freeInput,
  label: 'A',
  glyph: 'a',
  expected: <String>['a'],
);

class _FakeQuizNotifier extends QuizNotifier {
  @override
  Future<QuizState?> build() async => _state;

  @override
  Future<void> loadQuiz() async {
    state = const AsyncData<QuizState?>(_state);
  }

  @override
  void submitAnswer(String value) {
    state = const AsyncData<QuizState?>(
      QuizState(
        steps: <LessonStep>[_quizStep],
        currentIndex: 0,
        correctCount: 1,
        status: QuizStatus.correct,
      ),
    );
  }

  @override
  void next() {}
}

const QuizState _state = QuizState(
  steps: <LessonStep>[_quizStep],
  currentIndex: 0,
  correctCount: 0,
  status: QuizStatus.answering,
);
