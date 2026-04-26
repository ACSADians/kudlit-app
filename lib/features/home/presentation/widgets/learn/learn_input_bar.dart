import 'package:flutter/material.dart';

import 'draw_button.dart';

class LearnInputBar extends StatelessWidget {
  const LearnInputBar({
    super.key,
    required this.onDraw,
    required this.bottomPad,
    required this.processing,
    required this.done,
  });

  final VoidCallback? onDraw;
  final double bottomPad;
  final bool processing;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomPad),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: DrawButton(onTap: onDraw, processing: processing, done: done),
    );
  }
}
