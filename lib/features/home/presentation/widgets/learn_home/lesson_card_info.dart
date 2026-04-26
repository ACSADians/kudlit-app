import 'package:flutter/material.dart';

class LessonCardInfo extends StatelessWidget {
  const LessonCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'LESSON 1',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withAlpha(80),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Baybayin Basics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '3 vowels · 2 consonants',
            style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(140)),
          ),
        ],
      ),
    );
  }
}
