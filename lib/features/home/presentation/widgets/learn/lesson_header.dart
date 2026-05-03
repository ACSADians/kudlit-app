import 'package:flutter/material.dart';

class LessonHeader extends StatelessWidget {
  const LessonHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);
    final bool inLesson = onBack != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? cs.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: <Widget>[
              if (inLesson) ...<Widget>[
                GestureDetector(
                  onTap: onBack,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: cs.onSurface.withAlpha(170),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Text(
                inLesson ? 'Lesson 1' : 'Learn',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              if (inLesson) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  '· Vowels',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface.withAlpha(100),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
