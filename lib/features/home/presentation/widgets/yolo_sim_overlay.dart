import 'package:flutter/material.dart';

/// Mock YOLO detection overlay for web/design preview.
/// Replace this widget with real on-device inference output when YOLO is wired up.
class YoloSimOverlay extends StatelessWidget {
  const YoloSimOverlay({super.key});

  static const List<YoloDetection> _detections = <YoloDetection>[
    YoloDetection(conf: 0.96, top: 0.22, left: 0.08, width: 190, height: 58),
    YoloDetection(conf: 0.89, top: 0.42, left: 0.20, width: 230, height: 62),
    YoloDetection(conf: 0.83, top: 0.62, left: 0.12, width: 160, height: 54),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Stack(
      children: <Widget>[
        for (final YoloDetection d in _detections)
          Positioned(
            top: d.top * size.height,
            left: d.left * size.width,
            child: _DetectionBox(detection: d),
          ),
      ],
    );
  }
}

/// A single YOLO detection result — label, confidence, and fractional position.
class YoloDetection {
  const YoloDetection({
    required this.conf,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    this.label = 'baybayin',
  });

  final double conf;

  /// Fractional position from the top of the screen (0.0–1.0).
  final double top;

  /// Fractional position from the left of the screen (0.0–1.0).
  final double left;

  final double width;
  final double height;
  final String label;
}

class _DetectionBox extends StatelessWidget {
  const _DetectionBox({required this.detection});

  final YoloDetection detection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: detection.width,
      height: detection.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xD964D2FF), width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Positioned(
            top: -20,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xE664D2FF),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${detection.label} ${(detection.conf * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050A14),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
