import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_progress.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_progress_provider.dart';

import 'begin_button.dart';
import 'glyph_preview_row.dart';
import 'lesson_card_info.dart';

class LessonCard extends ConsumerWidget {
  const LessonCard({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.glyphCount,
    required this.estimatedLength,
    required this.items,
    required this.onStart,
    this.isLocked = false,
    this.lockedReason,
    this.progress,
  });

  final int index;
  final String title;
  final String subtitle;
  final int glyphCount;
  final String estimatedLength;
  final List<(String, String)> items;
  final VoidCallback onStart;
  final bool isLocked;
  final String? lockedReason;
  final LessonProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final LessonStatus status = progress?.status ?? LessonStatus.notStarted;

    final Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isLocked
                ? cs.surfaceContainerHigh.withAlpha(185)
                : cs.surface.withAlpha(198),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.primary.withAlpha(isLocked ? 18 : 42),
            ),
            boxShadow: isLocked
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: cs.primary.withAlpha(18),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  LessonCardInfo(
                    index: index,
                    title: title,
                    subtitle: subtitle,
                    glyphCount: glyphCount,
                    estimatedLength: estimatedLength,
                    status: _statusLabel(status, isLocked),
                    isLocked: isLocked,
                  ),
                  if (status != LessonStatus.notStarted && !isLocked)
                    Positioned(
                      top: 12,
                      right: 14,
                      child: _ProgressBadge(
                        status: status,
                        progress: progress,
                        cs: cs,
                      ),
                    ),
                ],
              ),
              if (items.isNotEmpty) GlyphPreviewRow(items: items),
              if (status == LessonStatus.inProgress && progress != null)
                _WaveProgressBar(fraction: progress!.progressFraction, cs: cs),
              BeginButton(
                onStart: onStart,
                isLocked: isLocked,
                lockedReason: lockedReason,
                label: _buttonLabel(status),
              ),
              if (status == LessonStatus.completed && !isLocked)
                _RestartButton(
                  cs: cs,
                  onRestart: () {
                    unawaited(
                      ref
                          .read(lessonProgressNotifierProvider.notifier)
                          .saveProgress(
                            LessonProgress(
                              lessonId: progress!.lessonId,
                              currentStepIndex: 0,
                              totalSteps: progress!.totalSteps,
                              completed: false,
                              score: 0,
                              lastModified: DateTime.now(),
                            ),
                          ),
                    );
                    onStart();
                  },
                ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: isLocked ? 0.58 : 1.0,
      child: cardContent,
    );
  }

  String _buttonLabel(LessonStatus status) {
    switch (status) {
      case LessonStatus.inProgress:
        return 'Resume';
      case LessonStatus.completed:
        return 'Review';
      case LessonStatus.notStarted:
        return 'Begin Lesson';
    }
  }

  String _statusLabel(LessonStatus status, bool locked) {
    if (locked) return 'Locked';
    switch (status) {
      case LessonStatus.inProgress:
        return 'In progress';
      case LessonStatus.completed:
        return 'Done';
      case LessonStatus.notStarted:
        return 'Ready';
    }
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.status,
    required this.progress,
    required this.cs,
  });

  final LessonStatus status;
  final LessonProgress? progress;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final bool done = status == LessonStatus.completed;
    final Color fgColor =
        done ? const Color(0xFF46B986) : const Color(0xFFF5A623);
    final String label = done
        ? '${progress?.score ?? 0}%'
        : 'Step ${(progress?.currentStepIndex ?? 0) + 1} / ${progress?.totalSteps ?? 0}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fgColor.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fgColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (done) ...<Widget>[
            Icon(Icons.check_rounded, size: 10, color: fgColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveProgressBar extends StatefulWidget {
  const _WaveProgressBar({required this.fraction, required this.cs});

  final double fraction;
  final ColorScheme cs;

  @override
  State<_WaveProgressBar> createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<_WaveProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: widget.fraction,
            minHeight: 5,
            backgroundColor: widget.cs.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5BB8FF)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: widget.fraction),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double animFraction, Widget? child) {
          return AnimatedBuilder(
            animation: _wave,
            builder: (BuildContext context, Widget? child) {
              return SizedBox(
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: CustomPaint(
                    painter: _WavePainter(
                      fraction: animFraction,
                      phase: _wave.value,
                      bgColor: widget.cs.surfaceContainerHighest,
                    ),
                    size: const Size(double.infinity, 6),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.fraction,
    required this.phase,
    required this.bgColor,
  });

  final double fraction;
  final double phase;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    if (fraction <= 0) return;

    final double fillWidth = size.width * fraction;
    final double wavePhase = phase * math.pi * 2;
    const double amplitude = 1.4;
    const double wavelength = 18.0;

    final Path path = Path()..moveTo(0, size.height / 2);

    for (double x = 0; x <= fillWidth + 1; x++) {
      final double y = size.height / 2 +
          amplitude *
              math.sin((x / wavelength) * math.pi * 2 + wavePhase);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path
      ..lineTo(fillWidth, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: const <Color>[Color(0xFF3F88C5), Color(0xFF5BB8FF)],
        ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height)),
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.phase != phase;
}

class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.cs, required this.onRestart});

  final ColorScheme cs;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: TextButton.icon(
          onPressed: onRestart,
          icon: Icon(
            Icons.replay_rounded,
            size: 14,
            color: cs.onSurface.withAlpha(120),
          ),
          label: Text(
            'Restart from beginning',
            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(120)),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ),
    );
  }
}
