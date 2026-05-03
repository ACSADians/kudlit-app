import 'package:flutter/material.dart';

import 'begin_button.dart';
import 'glyph_preview_row.dart';
import 'lesson_card_info.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onStart,
    this.isLocked = false,
  });

  final int index;
  final String title;
  final String subtitle;
  final List<(String, String)> items;
  final VoidCallback onStart;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
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
            LessonCardInfo(index: index, title: title, subtitle: subtitle),
            if (items.isNotEmpty) GlyphPreviewRow(items: items),
            BeginButton(onStart: onStart, isLocked: isLocked),
          ],
        ),
      ),
    );
  }
}
