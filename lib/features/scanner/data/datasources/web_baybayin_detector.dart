import 'dart:async';
import 'dart:typed_data';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

/// Web stub for [BaybayinDetector].
/// The camera and YOLO are unavailable on web, so this returns empty results.
class WebBaybayinDetector implements BaybayinDetector {
  @override
  Stream<List<BaybayinDetection>> get detections =>
      const Stream<List<BaybayinDetection>>.empty();

  @override
  Future<List<BaybayinDetection>> detectImage(Uint8List imageBytes) async =>
      const <BaybayinDetection>[];

  @override
  Future<void> toggleTorch({required bool enabled}) async {}

  @override
  void dispose() {}
}
