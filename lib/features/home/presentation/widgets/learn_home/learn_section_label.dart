import 'package:flutter/material.dart';

class LearnSectionLabel extends StatelessWidget {
  const LearnSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: cs.onSurface.withAlpha(100),
        letterSpacing: 1.4,
      ),
    );
  }
}
