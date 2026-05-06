import 'package:flutter/material.dart';

class EmptyOutput extends StatelessWidget {
  const EmptyOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/brand/ButtyPaint.webp',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Type or speak below\nto see Baybayin',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface.withAlpha(110),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
