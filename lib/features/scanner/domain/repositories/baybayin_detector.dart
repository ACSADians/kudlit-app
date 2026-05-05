import 'dart:typed_data';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';

/// Abstract interface for Baybayin detection.
///
/// Implementations:
/// - [YoloBaybayinDetector] — on-device YOLO (iOS / Android)
/// - [WebBaybayinDetector] — no-op stub for web
abstract class BaybayinDetector {
  /// Live stream of detections from the camera feed.
  /// Emits a new list each time the model processes a frame.
  Stream<List<BaybayinDetection>> get detections;

  /// Run inference on a single image (e.g. from the gallery).
  Future<List<BaybayinDetection>> detectImage(Uint8List imageBytes);

  /// Toggle the device torch / flash. No-op on web.
  Future<void> toggleTorch({required bool enabled});

  /// Switch between available camera lenses when the platform supports it.
  Future<void> switchCamera();

  /// Release all resources (camera, model).
  void dispose();
}
