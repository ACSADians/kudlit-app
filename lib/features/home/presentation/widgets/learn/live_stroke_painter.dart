import 'package:flutter/material.dart';

class LiveStrokePainter extends CustomPainter {
  const LiveStrokePainter({
    required this.strokes,
    required this.current,
    required this.strokeColor,
  });

  final List<List<Offset>> strokes;
  final List<Offset> current;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    _draw(canvas, strokes, paint);

    if (current.length >= 2) {
      paint.color = strokeColor.withAlpha(170);
      _draw(canvas, <List<Offset>>[current], paint);
    }
  }

  void _draw(Canvas canvas, List<List<Offset>> ss, Paint p) {
    for (final List<Offset> stroke in ss) {
      if (stroke.length < 2) continue;
      final Path path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(LiveStrokePainter old) => true;
}
