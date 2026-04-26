import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';

/// Draws a labelled bounding box for every [BaybayinDetection] in [detections].
///
/// All coordinates in [BaybayinDetection] are normalised (0–1) relative to the
/// widget's own size, so place this widget in a [Stack] that fills the same
/// area as the camera feed.
///
/// Example:
/// ```dart
/// Stack(
///   fit: StackFit.expand,
///   children: [
///     ScannerCamera(...),
///     DetectionOverlay(detections: detections),
///   ],
/// )
/// ```
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
  static const double _strokeWidth = 1.5;
  static const double _radius = 3;
  static const double _chipHeight = 18;
  static const double _chipPadH = 6;
  static const double _chipFontSize = 10;

  final Paint _boxPaint = Paint()
    ..color = _boxColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth;

  final Paint _chipPaint = Paint()
    ..color = _chipBg
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (final BaybayinDetection d in detections) {
      final Rect rect = Rect.fromLTWH(
        d.left * size.width,
        d.top * size.height,
        d.width * size.width,
        d.height * size.height,
      );

      // bounding box
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(_radius)),
        _boxPaint,
      );

      // label chip
      final String label = '${d.label} ${(d.confidence * 100).round()}%';
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: _chipFontSize,
            fontWeight: FontWeight.w700,
            color: _chipText,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double chipW = tp.width + _chipPadH * 2;
      final Rect chipRect = Rect.fromLTWH(
        rect.left,
        rect.top - _chipHeight,
        chipW,
        _chipHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chipRect, const Radius.circular(_radius)),
        _chipPaint,
      );
      tp.paint(
        canvas,
        Offset(
          chipRect.left + _chipPadH,
          chipRect.top + (_chipHeight - tp.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_DetectionPainter old) => old.detections != detections;
}
