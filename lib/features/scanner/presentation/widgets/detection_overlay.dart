import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';

/// Draws a single aggregated bounding box around all [detections] and shows
/// the concatenated detected string above it.
///
/// Detections are sorted left-to-right by their `left` coordinate to produce
/// the reading order. Post-processing of the joined string (kudlit handling,
/// spelling normalisation, etc.) happens elsewhere — this widget just shows
/// the raw concatenation.
class DetectionOverlay extends StatelessWidget {
  const DetectionOverlay({required this.detections, super.key});

  final List<BaybayinDetection> detections;

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _DetectionPainter(detections: detections),
      child: const SizedBox.expand(),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _DetectionPainter extends CustomPainter {
  _DetectionPainter({required this.detections});

  final List<BaybayinDetection> detections;

  static const Color _boxColor = Color(0xD964D2FF);
  static const Color _chipBg = Color(0xE664D2FF);
  static const Color _chipText = Color(0xFF050A14);
  static const double _strokeWidth = 2;
  static const double _radius = 6;
  static const double _chipPadH = 10;
  static const double _chipPadV = 6;
  static const double _chipFontSize = 14;
  static const double _boxPadding = 8;

  final Paint _boxPaint = Paint()
    ..color = _boxColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth;

  final Paint _chipPaint = Paint()
    ..color = _chipBg
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    // Reading order: left → right.
    final List<BaybayinDetection> ordered =
        List<BaybayinDetection>.of(detections)..sort(
          (BaybayinDetection a, BaybayinDetection b) =>
              a.left.compareTo(b.left),
        );

    final String joined = ordered.map((BaybayinDetection d) => d.label).join();

    // Union of all boxes, in pixel space.
    Rect union = _toRect(ordered.first, size);
    for (int i = 1; i < ordered.length; i++) {
      union = union.expandToInclude(_toRect(ordered[i], size));
    }
    union = union.inflate(_boxPadding);

    canvas.drawRRect(
      RRect.fromRectAndRadius(union, const Radius.circular(_radius)),
      _boxPaint,
    );

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: joined,
        style: const TextStyle(
          fontSize: _chipFontSize,
          fontWeight: FontWeight.w700,
          color: _chipText,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32);

    final double chipW = tp.width + _chipPadH * 2;
    final double chipH = tp.height + _chipPadV * 2;

    // Anchor the chip at the top-left of the union; clamp inside the view.
    double chipLeft = union.left;
    if (chipLeft + chipW > size.width) {
      chipLeft = size.width - chipW - 4;
    }
    if (chipLeft < 4) chipLeft = 4;
    double chipTop = union.top - chipH - 4;
    if (chipTop < 4) chipTop = union.bottom + 4;

    final Rect chipRect = Rect.fromLTWH(chipLeft, chipTop, chipW, chipH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(_radius)),
      _chipPaint,
    );
    tp.paint(
      canvas,
      Offset(chipRect.left + _chipPadH, chipRect.top + _chipPadV),
    );
  }

  Rect _toRect(BaybayinDetection d, Size size) => Rect.fromLTWH(
    d.left * size.width,
    d.top * size.height,
    d.width * size.width,
    d.height * size.height,
  );

  @override
  bool shouldRepaint(_DetectionPainter old) => old.detections != detections;
}
