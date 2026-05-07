import 'dart:typed_data';

import 'package:kudlit_ph/features/scanner/data/datasources/web_vision_model_url_resolver.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

BaybayinDetector createPlatformWebBaybayinDetector({
  required WebVisionModelUrlResolver modelUrlResolver,
}) {
  return const WebBaybayinDetectorStub();
}

class WebBaybayinDetectorStub implements BaybayinDetector {
  const WebBaybayinDetectorStub();

  @override
  Stream<List<BaybayinDetection>> get detections =>
      const Stream<List<BaybayinDetection>>.empty();

  @override
  Future<List<BaybayinDetection>> detectImage(Uint8List imageBytes) async =>
      const <BaybayinDetection>[];

  @override
  Future<void> toggleTorch({required bool enabled}) async {}

  @override
  Future<void> switchCamera() async {}

  @override
  Future<void> pauseInference() async {}

  @override
  Future<void> resumeInference() async {}

  @override
  void dispose() {}
}
