import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  test('disposes still-image YOLO instance when model loading fails', () async {
    late _FailingYolo failingYolo;
    final YoloBaybayinDetector detector = YoloBaybayinDetector(
      modelPathResolver: () async => 'bad-model.tflite',
      singleImageYoloFactory: (String modelPath) {
        failingYolo = _FailingYolo(modelPath: modelPath);
        return failingYolo;
      },
    );
    addTearDown(detector.dispose);

    await expectLater(
      detector.detectImage(Uint8List(0)),
      throwsA(isA<StateError>()),
    );

    expect(failingYolo.loadCalls, 1);
    expect(failingYolo.disposeCalls, 1);
  });
}

class _FailingYolo extends YOLO {
  _FailingYolo({required super.modelPath}) : super(useMultiInstance: false);

  int loadCalls = 0;
  int disposeCalls = 0;

  @override
  Future<bool> loadModel() async {
    loadCalls += 1;
    throw StateError('bad model');
  }

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
  }
}
