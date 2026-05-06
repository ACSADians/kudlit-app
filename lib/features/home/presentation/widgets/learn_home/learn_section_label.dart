import 'package:flutter/material.dart';

class LearnSectionLabel extends StatelessWidget {
  const LearnSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withAlpha(100),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        CustomPaint(
          size: const Size(38, 5),
          painter: _WaveUnderlinePainter(color: cs.primary.withAlpha(110)),
        ),
      ],
    );
  }
}

class _WaveUnderlinePainter extends CustomPainter {
  const _WaveUnderlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width,
        size.height / 2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveUnderlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
