import 'package:flutter/material.dart';

import 'output_actions.dart';

class FilledOutput extends StatelessWidget {
  const FilledOutput({super.key, required this.baybayin, required this.latin});

  final String baybayin;
  final String latin;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            baybayin,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: 54,
              color: cs.onSurface,
              letterSpacing: 10,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(width: 40, height: 1.5, color: cs.outline),
        const SizedBox(height: 14),
        Text(
          latin,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withAlpha(190),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 24),
        const OutputActions(),
      ],
    );
  }
}
