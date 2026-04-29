import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

/// On-device YOLO implementation of [BaybayinDetector] for iOS and Android.
///
/// The live preview model path is supplied by `yoloModelPathProvider` (in the
/// scanner presentation layer), which downloads the active catalog model on
/// demand and surfaces [ModelNotReadyScreen] until it is ready.
class YoloBaybayinDetector implements BaybayinDetector {
  YoloBaybayinDetector() : _controller = YOLOViewController() {
    debugPrint('[YOLO] YoloBaybayinDetector created');
  }

  final YOLOViewController _controller;
  final StreamController<List<BaybayinDetection>> _streamController =
      StreamController<List<BaybayinDetection>>.broadcast();

  /// The [YOLOViewController] — pass this to [YOLOView].
  YOLOViewController get controller => _controller;

  /// Called by [YOLOView.onResult] to push detections into the stream.
  void onYoloResults(List<YOLOResult> results) {
    debugPrint(
      '[YOLO] onYoloResults: ${results.length} detection(s) — '
      '${results.map((YOLOResult r) => '${r.className}(${(r.confidence * 100).toStringAsFixed(1)}%)').join(', ')}',
    );
    final List<BaybayinDetection> detections = results
        .map(
          (YOLOResult r) => BaybayinDetection(
            label: r.className,
            confidence: r.confidence,
            left: r.normalizedBox.left,
            top: r.normalizedBox.top,
            width: r.normalizedBox.width,
            height: r.normalizedBox.height,
          ),
        )
        .toList();
    if (!_streamController.isClosed) {
      _streamController.add(detections);
    }
  }

  @override
  Stream<List<BaybayinDetection>> get detections => _streamController.stream;

  @override
  Future<List<BaybayinDetection>> detectImage(Uint8List imageBytes) async {
    // Single-image inference is not yet wired into the model-selection
    // pipeline — it cannot resolve which catalog model + version to use
    // without a scope. Use the live preview path (`YOLOView`) for now.
    throw UnimplementedError(
      'detectImage requires a scope-aware model resolver — '
      'see yoloModelPathProvider in the scanner presentation layer.',
    );
  }

  @override
  Future<void> toggleTorch({required bool enabled}) =>
      _controller.setTorchMode(enabled);

  @override
  void dispose() {
    debugPrint('[YOLO] YoloBaybayinDetector disposed');
    _streamController.close();
  }
}
