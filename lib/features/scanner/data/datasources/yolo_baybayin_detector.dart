import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

/// On-device YOLO implementation of [BaybayinDetector] for iOS and Android.
///
/// The model path is always resolved from [YoloModelCache] — no bundled asset
/// fallback. The scanner UI gates this via `yoloModelPathProvider`, which
/// surfaces [ModelNotReadyScreen] until the model has been downloaded.
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
    // Prefer the downloaded model; fall back to the bundled asset.
    final String modelPath = await YoloModelCache.instance.resolvedModelPath();
    debugPrint('[YOLO] detectImage: loading model from $modelPath …');
    final YOLO yolo = YOLO(modelPath: modelPath, task: YOLOTask.detect);
    await yolo.loadModel();
    debugPrint(
      '[YOLO] detectImage: model loaded — running predict on '
      '${imageBytes.lengthInBytes} bytes …',
    );
    final Map<String, dynamic> raw = await yolo.predict(imageBytes);
    debugPrint(
      '[YOLO] detectImage: predict complete — raw keys: ${raw.keys.toList()}',
    );
    final List<dynamic> detections =
        (raw['detections'] as List<dynamic>?) ?? <dynamic>[];
    return detections
        .map((dynamic d) => YOLOResult.fromMap(d as Map))
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
