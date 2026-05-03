import 'package:flutter/material.dart';

import 'attempt_meta.dart';
import 'stroke_thumbnail.dart';

class UserAttemptCard extends StatelessWidget {
  const UserAttemptCard({
    super.key,
    required this.strokes,
    required this.detected,
  });

  final List<List<Offset>> strokes;
  final String detected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.7,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StrokeThumbnail(strokes: strokes),
              const SizedBox(width: 12),
              AttemptMeta(detected: detected),
            ],
          ),
        ),
      ),
    );
  }
}
