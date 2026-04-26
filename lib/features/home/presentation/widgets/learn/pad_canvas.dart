import 'package:flutter/material.dart';

import 'live_stroke_painter.dart';

class PadCanvas extends StatelessWidget {
  const PadCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: GestureDetector(
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: CustomPaint(
              painter: LiveStrokePainter(
                strokes: strokes,
                current: currentStroke,
                strokeColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
