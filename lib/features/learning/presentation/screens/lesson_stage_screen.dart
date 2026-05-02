import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_mode.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_controller.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/butty_coach_panel.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/butty_help_sheet.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/lesson_progress_bar.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/lesson_top_bar.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/modes/draw_mode_body.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/modes/free_input_mode_body.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/modes/reference_mode_body.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';

class LessonStageScreen extends ConsumerStatefulWidget {
  const LessonStageScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonStageScreen> createState() => _LessonStageScreenState();
}

class _LessonStageScreenState extends ConsumerState<LessonStageScreen> {
  final GlobalKey<DrawModeBodyState> _drawKey = GlobalKey<DrawModeBodyState>();
  final GlobalKey<FreeInputModeBodyState> _freeKey =
      GlobalKey<FreeInputModeBodyState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonControllerProvider.notifier).loadLesson(widget.lessonId);
    });
  }

  void _openHelp(LessonStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ButtyHelpSheet(step: step),
    );
  }

  void _handleContinue(LessonState state) {
    final LessonController ctrl = ref.read(lessonControllerProvider.notifier);
    if (state.completed) {
      Navigator.of(context).pop();
      return;
    }
    if (state.attemptStatus == AttemptStatus.correct) {
      ctrl.next();
      return;
    }
    switch (state.currentStep.mode) {
      case LessonMode.reference:
        ctrl.acknowledge();
      case LessonMode.draw:
        _drawKey.currentState?.submitToController();
      case LessonMode.freeInput:
        _freeKey.currentState?.submitToController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LessonState?> async = ref.watch(lessonControllerProvider);
    // Watch the drawing-pad YOLO model so it starts loading immediately and
    // Riverpod keeps the instance alive for the duration of this screen.
    if (!kIsWeb) ref.watch(yoloDrawingPadModelProvider);
    return Scaffold(
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => _ErrorView(message: e.toString()),
          data: (LessonState? data) {
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _LessonScaffold(
              state: data,
              drawKey: _drawKey,
              freeKey: _freeKey,
              onOpenHelp: _openHelp,
              onContinue: () => _handleContinue(data),
            );
          },
        ),
      ),
    );
  }
}

class _LessonScaffold extends StatelessWidget {
  const _LessonScaffold({
    required this.state,
    required this.drawKey,
    required this.freeKey,
    required this.onOpenHelp,
    required this.onContinue,
  });

  final LessonState state;
  final GlobalKey<DrawModeBodyState> drawKey;
  final GlobalKey<FreeInputModeBodyState> freeKey;
  final void Function(LessonStep step) onOpenHelp;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final LessonStep step = state.currentStep;
    return Column(
      children: <Widget>[
        LessonTopBar(
          title: state.lesson.title,
          subtitle: state.lesson.subtitle,
          onClose: () => Navigator.of(context).pop(),
        ),
        LessonProgressBar(
          progress: state.progress,
          label:
              'Step ${state.currentStepIndex + 1} of '
              '${state.lesson.steps.length} — ${step.label}',
        ),
        Expanded(
          child: _ModeSwitcher(
            step: step,
            status: state.attemptStatus,
            drawKey: drawKey,
            freeKey: freeKey,
          ),
        ),
        ButtyCoachPanel(
          message: state.buttyMessage,
          attemptStatus: state.attemptStatus,
          completed: state.completed,
          onContinue: onContinue,
          onAvatarTap: () => onOpenHelp(step),
          onAskHelp: () => onOpenHelp(step),
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.step,
    required this.status,
    required this.drawKey,
    required this.freeKey,
  });

  final LessonStep step;
  final AttemptStatus status;
  final GlobalKey<DrawModeBodyState> drawKey;
  final GlobalKey<FreeInputModeBodyState> freeKey;

  @override
  Widget build(BuildContext context) {
    switch (step.mode) {
      case LessonMode.reference:
        return ReferenceModeBody(step: step, attemptStatus: status);
      case LessonMode.draw:
        return DrawModeBody(key: drawKey, step: step, attemptStatus: status);
      case LessonMode.freeInput:
        return FreeInputModeBody(
          key: freeKey,
          step: step,
          attemptStatus: status,
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
