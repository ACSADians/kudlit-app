import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: cs.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Align(
              key: ValueKey<String>(label),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
