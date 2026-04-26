import 'package:flutter/material.dart';

class AttemptMeta extends StatelessWidget {
  const AttemptMeta({super.key, required this.detected});

  final String detected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Your attempt',
          style: TextStyle(fontSize: 10, color: cs.onSurface.withAlpha(120)),
        ),
        const SizedBox(height: 4),
        Text(
          detected,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Sent for review',
          style: TextStyle(fontSize: 10, color: cs.onSurface.withAlpha(100)),
        ),
      ],
    );
  }
}
