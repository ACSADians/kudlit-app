import 'package:flutter/material.dart';

class ButtyChatCta extends StatelessWidget {
  const ButtyChatCta({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          'Start chat',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward_rounded, size: 14, color: cs.primary),
      ],
    );
  }
}
