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
    required this.glyphCount,
    required this.estimatedLength,
    required this.status,
    required this.items,
    required this.onStart,
    this.isLocked = false,
    this.lockedReason,
  });

  final int index;
  final String title;
  final String subtitle;
  final int glyphCount;
  final String estimatedLength;
  final String status;
  final List<(String, String)> items;
  final VoidCallback onStart;
  final bool isLocked;
  final String? lockedReason;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isLocked ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LessonCardInfo(
            index: index,
            title: title,
            subtitle: subtitle,
            glyphCount: glyphCount,
            estimatedLength: estimatedLength,
            status: status,
            isLocked: isLocked,
          ),
          if (items.isNotEmpty) GlyphPreviewRow(items: items),
          BeginButton(
            onStart: onStart,
            isLocked: isLocked,
            lockedReason: lockedReason,
          ),
        ],
      ),
    );
  }
}
