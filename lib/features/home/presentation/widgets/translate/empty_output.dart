import 'package:flutter/material.dart';

class EmptyOutput extends StatelessWidget {
  const EmptyOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.text_fields_rounded,
          size: 36,
          color: cs.onSurface.withAlpha(60),
        ),
        const SizedBox(height: 10),
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
