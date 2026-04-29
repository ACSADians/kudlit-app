import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/challenge_pin_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/drawing_pad_sheet.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/learn_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/lesson_event.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/lesson_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/lesson_thread.dart';
import 'learn_home_body.dart';

// ─── Lesson steps ─────────────────────────────────────────────────────────────

class _LessonStep {
  const _LessonStep({
    required this.intro,
    required this.glyph,
    required this.label,
    required this.feedback,
    required this.followUp,
  });

  final String intro;
  final String glyph;
  final String label;
  final String feedback;
  final String followUp;
}

const List<_LessonStep> _kSteps = <_LessonStep>[
  _LessonStep(
    intro:
        'Let\'s start with the three Baybayin vowels. First: the vowel A. '
        'Study the shape below, then draw it on the pad.',
    glyph: 'a',
    label: 'A',
    feedback:
        'Correct. Your curve is clean — the tail lifts from the bottom-right.',
    followUp:
        'A is the foundation of Baybayin. Almost every syllable starts here. '
        'Next: E and I share a single glyph. Study it, then draw.',
  ),
  _LessonStep(
    intro: '',
    glyph: 'e',
    label: 'E / I',
    feedback:
        'Good. Notice the mirrored curve — same base as A, opposite direction.',
    followUp:
        'Last vowel. O and U also share a glyph in Baybayin — a clean circle. '
        'Draw it.',
  ),
  _LessonStep(
    intro: '',
    glyph: 'o',
    label: 'O / U',
    feedback:
        'Tama! The circle closes cleanly. That is the mark of a solid O/U.',
    followUp:
        'You have written all three Baybayin vowels. Now we move to '
        'consonants. Without a diacritic, every consonant defaults to the '
        '"a" vowel sound. Draw B — it reads as "ba".',
  ),
  _LessonStep(
    intro: '',
    glyph: 'b',
    label: 'BA',
    feedback: 'Nice control. The loop is balanced and the tail is clean.',
    followUp:
        'Solid work. Now the consonant K — it reads as "ka" by default. '
        'Keep the strokes deliberate.',
  ),
  _LessonStep(
    intro: '',
    glyph: 'k',
    label: 'KA',
    feedback: 'Clean. You are building strong muscle memory.',
    followUp:
        'That completes this lesson set. You have learned 3 vowels and '
        '2 consonants. More lessons are on the way.',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class LearnTab extends StatefulWidget {
  const LearnTab({super.key, required this.onSwitchToButty});

  final VoidCallback onSwitchToButty;

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  final ScrollController _scroll = ScrollController();
  final List<LessonEvent> _events = <LessonEvent>[];
  int _stepIndex = 0;
  bool _processingAttempt = false;
  bool _lessonDone = false;
  bool _inLesson = false;

  @override
  void initState() {
    super.initState();
    _events.add(LessonEvent.butty(_kSteps[0].intro));
    _events.add(
      LessonEvent.challenge(glyph: _kSteps[0].glyph, label: _kSteps[0].label),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onAttemptSubmitted(List<List<Offset>> strokes) {
    if (_processingAttempt || _lessonDone) return;
    setState(() {
      _processingAttempt = true;
      _events.add(
        LessonEvent.attempt(
          strokes: strokes,
          detected: _kSteps[_stepIndex].label,
        ),
      );
    });
    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 700), _addFeedback);
  }

  void _addFeedback() {
    if (!mounted) return;
    setState(() {
      _events.add(
        LessonEvent.feedback(correct: true, text: _kSteps[_stepIndex].feedback),
      );
    });
    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 800), _addFollowUp);
  }

  void _addFollowUp() {
    if (!mounted) return;
    setState(() {
      _events.add(LessonEvent.butty(_kSteps[_stepIndex].followUp));
    });
    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 500), _advanceStep);
  }

  void _advanceStep() {
    if (!mounted) return;
    final int next = _stepIndex + 1;
    if (next < _kSteps.length) {
      setState(() {
        _stepIndex = next;
        _events.add(
          LessonEvent.challenge(
            glyph: _kSteps[next].glyph,
            label: _kSteps[next].label,
          ),
        );
        _processingAttempt = false;
      });
    } else {
      setState(() {
        _lessonDone = true;
        _processingAttempt = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openDrawingPad() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DrawingPadSheet(
        targetGlyph: _kSteps[_stepIndex].glyph,
        targetLabel: _kSteps[_stepIndex].label,
        onSubmit: _onAttemptSubmitted,
      ),
    );
  }

  void _startLesson() {
    GoRouter.of(context).push('${AppConstants.routeLesson}/vowels-01');
  }

  void _backToHome() {
    setState(() {
      _inLesson = false;
      _events
        ..clear()
        ..add(LessonEvent.butty(_kSteps[0].intro))
        ..add(
          LessonEvent.challenge(
            glyph: _kSteps[0].glyph,
            label: _kSteps[0].label,
          ),
        );
      _stepIndex = 0;
      _processingAttempt = false;
      _lessonDone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.paddingOf(context).bottom + kFloatingNavClearance;

    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: <Widget>[
          if (_inLesson) LessonHeader(onBack: _backToHome),
          if (_inLesson)
            _LessonContent(
              events: _events,
              scroll: _scroll,
              steps: _kSteps,
              stepIndex: _stepIndex,
              lessonDone: _lessonDone,
              processingAttempt: _processingAttempt,
              onDraw: _openDrawingPad,
              bottomPad: bottomPad,
            )
          else
            Expanded(
              child: LearnHomeBody(
                onStart: _startLesson,
                onChatWithButty: widget.onSwitchToButty,
                bottomPad: bottomPad,
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonContent extends StatelessWidget {
  const _LessonContent({
    required this.events,
    required this.scroll,
    required this.steps,
    required this.stepIndex,
    required this.lessonDone,
    required this.processingAttempt,
    required this.onDraw,
    required this.bottomPad,
  });

  final List<LessonEvent> events;
  final ScrollController scroll;
  final List<_LessonStep> steps;
  final int stepIndex;
  final bool lessonDone;
  final bool processingAttempt;
  final VoidCallback onDraw;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Expanded(
            child: LessonThread(events: events, scroll: scroll),
          ),
          if (!lessonDone)
            ChallengePinBar(
              glyph: steps[stepIndex].glyph,
              label: steps[stepIndex].label,
            ),
          LearnInputBar(
            onDraw: (!processingAttempt && !lessonDone) ? onDraw : null,
            bottomPad: bottomPad,
            processing: processingAttempt,
            done: lessonDone,
          ),
        ],
      ),
    );
  }
}
