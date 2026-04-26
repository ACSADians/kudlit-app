import 'package:flutter/material.dart';

import 'begin_button.dart';
import 'glyph_preview_row.dart';
import 'lesson_card_info.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const LessonCardInfo(),
          const GlyphPreviewRow(),
          BeginButton(onStart: onStart),
        ],
      ),
    );
  }
}
