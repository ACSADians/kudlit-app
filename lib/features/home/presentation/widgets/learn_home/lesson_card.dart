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
  });

  final int index;
  final String title;
  final String subtitle;
  final List<(String, String)> items;
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
          LessonCardInfo(index: index, title: title, subtitle: subtitle),
          if (items.isNotEmpty) GlyphPreviewRow(items: items),
          BeginButton(onStart: onStart),
        ],
      ),
    );
  }
}
