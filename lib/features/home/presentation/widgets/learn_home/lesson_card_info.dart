import 'package:flutter/material.dart';

class LessonCardInfo extends StatelessWidget {
  const LessonCardInfo({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.glyphCount,
    required this.estimatedLength,
    required this.status,
    required this.isLocked,
  });

  final int index;
  final String title;
  final String subtitle;
  final int glyphCount;
  final String estimatedLength;
  final String status;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'LESSON $index',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withAlpha(80),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: isLocked
                        ? cs.onSurface.withValues(alpha: 0.62)
                        : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _MetaChip(
                label: status,
                icon: isLocked
                    ? Icons.lock_rounded
                    : status == 'Done'
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(140)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaChip(
                icon: Icons.auto_stories_rounded,
                label: '$glyphCount glyph${glyphCount == 1 ? '' : 's'}',
              ),
              _MetaChip(icon: Icons.schedule_rounded, label: estimatedLength),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
