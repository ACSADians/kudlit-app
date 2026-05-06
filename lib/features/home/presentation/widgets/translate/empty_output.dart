import 'package:flutter/material.dart';

class EmptyOutput extends StatelessWidget {
  const EmptyOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Empty translation output',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.text_fields_rounded,
              size: 34,
              color: cs.onSurface.withAlpha(120),
            ),
            const SizedBox(height: 10),
            Text(
              'Type or speak below\nto see Baybayin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: cs.onSurface.withAlpha(170),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
