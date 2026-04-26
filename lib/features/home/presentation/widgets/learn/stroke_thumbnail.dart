import 'package:flutter/material.dart';

import 'thumbnail_painter.dart';

class StrokeThumbnail extends StatelessWidget {
  const StrokeThumbnail({super.key, required this.strokes});

  final List<List<Offset>> strokes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 60,
        height: 60,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: CustomPaint(
          painter: ThumbnailPainter(
            strokes: strokes,
            strokeColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
