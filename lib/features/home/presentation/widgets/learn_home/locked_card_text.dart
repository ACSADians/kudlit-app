import 'package:flutter/material.dart';

class LockedCardText extends StatelessWidget {
  const LockedCardText({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final int index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
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
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withAlpha(120),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5,
            color: cs.onSurface.withAlpha(80),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
