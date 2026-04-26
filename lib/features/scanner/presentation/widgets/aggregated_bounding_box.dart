import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';

/// Draws a single "union" bounding box that wraps all detections, plus a
/// scrim that dims everything outside it.
///
/// All coordinates in [BaybayinDetection] are normalised (0–1).  Place this
/// widget in a [Stack] that fills the same area as the camera feed.
///
/// Returns an empty widget when [detections] is empty.
///
/// Example:
/// ```dart
/// Stack(
///   fit: StackFit.expand,
///   children: [
///     ScannerCamera(...),
///     AggregatedBoundingBox(detections: detections),
///   ],
/// )
/// ```
class AggregatedBoundingBox extends StatelessWidget {
  const AggregatedBoundingBox({required this.detections, super.key});

  final List<BaybayinDetection> detections;

  /// Computes the union [Rect] in normalised (0–1) space.
  static Rect? unionRect(List<BaybayinDetection> detections) {
    if (detections.isEmpty) return null;
    double left = double.infinity;
    double top = double.infinity;
    double right = double.negativeInfinity;
    double bottom = double.negativeInfinity;
    for (final BaybayinDetection d in detections) {
      if (d.left < left) left = d.left;
      if (d.top < top) top = d.top;
      final double r = d.left + d.width;
      final double b = d.top + d.height;
      if (r > right) right = r;
      if (b > bottom) bottom = b;
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    final Rect? norm = unionRect(detections);
    if (norm == null) return const SizedBox.shrink();
    return CustomPaint(
      painter: _AggregatedPainter(normalizedRect: norm),
      child: const SizedBox.expand(),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _AggregatedPainter extends CustomPainter {
  _AggregatedPainter({required this.normalizedRect});

  final Rect normalizedRect;

  static const Color _boxColor = Color(0xFF4CFFA0);
  static const Color _scrimColor = Color(0x66000000);
  static const double _strokeWidth = 2.0;
  static const double _radius = 6.0;
  static const double _padding = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Rect.fromLTRB(
      normalizedRect.left * size.width - _padding,
      normalizedRect.top * size.height - _padding,
      normalizedRect.right * size.width + _padding,
      normalizedRect.bottom * size.height + _padding,
    ).intersect(Offset.zero & size); // clamp to canvas bounds

    // Scrim outside the aggregated box
    final Path scrim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(box, const Radius.circular(_radius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = _scrimColor);

    // Aggregated box stroke
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(_radius)),
      Paint()
        ..color = _boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_AggregatedPainter old) =>
      old.normalizedRect != normalizedRect;
}
