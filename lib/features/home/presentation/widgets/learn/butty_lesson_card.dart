import 'package:flutter/material.dart';

class ButtyLessonCard extends StatelessWidget {
  const ButtyLessonCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/brand/ButtyRead.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: cs.onSurface.withAlpha(220),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
