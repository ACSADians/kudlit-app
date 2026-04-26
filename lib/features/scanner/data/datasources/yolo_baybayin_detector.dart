import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

/// Asset path to the bundled Baybayin model, resolved per platform.
///
/// - iOS  : `assets/models/baybayin_yolo.mlpackage.zip` (Core ML, NMS=true)
/// - Android: `assets/models/baybayin_yolo.tflite`
///
/// Until the model is exported, the official placeholder `'yolo26n'` is used
/// so the code compiles; [_kModelAvailable] in scanner_camera.dart gates
/// whether the view is actually shown.
String get _kModelPath => Platform.isIOS
    ? 'assets/models/baybayin_yolo.mlpackage.zip'
    : 'assets/models/baybayin_yolo.tflite';

/// On-device YOLO implementation of [BaybayinDetector] for iOS and Android.
///
/// Pass the [controller] from the [YOLOView] after it is created so the
/// detector can toggle the torch and capture frames.
class YoloBaybayinDetector implements BaybayinDetector {
  YoloBaybayinDetector() : _controller = YOLOViewController() {
    debugPrint('[YOLO] YoloBaybayinDetector created — modelPath: $_kModelPath');
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
    debugPrint('[YOLO] detectImage: loading model from $_kModelPath …');
    final YOLO yolo = YOLO(modelPath: _kModelPath, task: YOLOTask.detect);
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
