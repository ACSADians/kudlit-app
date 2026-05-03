import 'package:meta/meta.dart';

/// A single Baybayin character detection result from the YOLO model.
@immutable
class BaybayinDetection {
  const BaybayinDetection({
    required this.label,
    required this.confidence,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Detected character label (e.g. 'ba', 'ka').
  final String label;

  /// Confidence score in 0–1.
  final double confidence;

  /// Bounding box — all values normalised to 0–1 relative to the view.
  final double left;
  final double top;
  final double width;
  final double height;

  @override
  String toString() =>
      'BaybayinDetection(label: $label, conf: ${confidence.toStringAsFixed(2)}, '
      'box: [$left, $top, $width, $height])';
}
