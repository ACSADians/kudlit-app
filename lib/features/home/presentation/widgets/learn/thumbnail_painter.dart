import 'package:flutter/material.dart';

class ThumbnailPainter extends CustomPainter {
  const ThumbnailPainter({required this.strokes, required this.strokeColor});

  final List<List<Offset>> strokes;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> all = strokes.expand((List<Offset> s) => s).toList();
    if (all.length < 2) return;

    double minX = all[0].dx, maxX = all[0].dx;
    double minY = all[0].dy, maxY = all[0].dy;
    for (final Offset o in all) {
      if (o.dx < minX) minX = o.dx;
      if (o.dx > maxX) maxX = o.dx;
      if (o.dy < minY) minY = o.dy;
      if (o.dy > maxY) maxY = o.dy;
    }

    final double range = (maxX - minX) > (maxY - minY)
        ? (maxX - minX)
        : (maxY - minY);
    if (range == 0) return;

    const double pad = 6.0;
    final double scale = (size.width - pad * 2) / range;

    Offset norm(Offset o) =>
        Offset((o.dx - minX) * scale + pad, (o.dy - minY) * scale + pad);

    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final List<Offset> stroke in strokes) {
      if (stroke.length < 2) continue;
      final Path path = Path()..moveTo(norm(stroke[0]).dx, norm(stroke[0]).dy);
      for (int i = 1; i < stroke.length; i++) {
        final Offset n = norm(stroke[i]);
        path.lineTo(n.dx, n.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ThumbnailPainter old) =>
      old.strokes != strokes || old.strokeColor != strokeColor;
}
