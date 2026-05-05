import 'dart:async';

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
    required this.items,
    required this.onStart,
    this.isLocked = false,
    this.progress,
  });

  final int index;
  final String title;
  final String subtitle;
  final List<(String, String)> items;
  final VoidCallback onStart;
  final bool isLocked;
  final LessonProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final LessonStatus status = progress?.status ?? LessonStatus.notStarted;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CardHeader(
              index: index,
              title: title,
              subtitle: subtitle,
              status: status,
              progress: progress,
              cs: cs,
            ),
            if (items.isNotEmpty) GlyphPreviewRow(items: items),
            if (status == LessonStatus.inProgress && progress != null)
              _ProgressBar(fraction: progress!.progressFraction, cs: cs),
            BeginButton(
              onStart: onStart,
              isLocked: isLocked,
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
    );
  }

  String _buttonLabel(LessonStatus status) {
    switch (status) {
      case LessonStatus.inProgress:
        return 'Resume';
      case LessonStatus.completed:
        return 'Review';
      case LessonStatus.notStarted:
        return 'Begin';
    }
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    required this.cs,
  });

  final int index;
  final String title;
  final String subtitle;
  final LessonStatus status;
  final LessonProgress? progress;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LessonCardInfo(index: index, title: title, subtitle: subtitle),
        if (status != LessonStatus.notStarted)
          Positioned(
            top: 12,
            right: 14,
            child: _StatusBadge(status: status, progress: progress, cs: cs),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
    final Color bgColor = done
        ? const Color(0xFF46B986).withAlpha(30)
        : const Color(0xFFF5A623).withAlpha(30);
    final Color fgColor = done
        ? const Color(0xFF46B986)
        : const Color(0xFFF5A623);

    final String label = done
        ? '${progress?.score ?? 0}%'
        : 'Step ${(progress?.currentStepIndex ?? 0)} / ${progress?.totalSteps ?? 0}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction, required this.cs});

  final double fraction;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: fraction,
          minHeight: 4,
          backgroundColor: cs.surfaceContainerHighest,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5A623)),
        ),
      ),
    );
  }
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
          icon: Icon(Icons.replay_rounded, size: 14, color: cs.onSurface.withAlpha(120)),
          label: Text(
            'Restart from beginning',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withAlpha(120),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ),
    );
  }
}
