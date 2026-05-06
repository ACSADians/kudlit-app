import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:tflite_web/tflite_web.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/web_vision_model_url_resolver.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/web_yolo_output_parser.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

const List<String> kBaybayinWebYoloLabels = <String>[
  'a',
  'e',
  'o',
  'k',
  'g',
  'ng',
  't',
  'd',
  'n',
  'p',
  'b',
  'bi',
  'bu',
  'm',
  'y',
  'l',
  'w',
  's',
  'h',
];

BaybayinDetector createPlatformWebBaybayinDetector({
  required WebVisionModelUrlResolver modelUrlResolver,
}) {
  return WebTfliteBaybayinDetector(modelUrlResolver: modelUrlResolver);
}

class WebTfliteBaybayinDetector implements BaybayinDetector {
  WebTfliteBaybayinDetector({required this.modelUrlResolver});

  final WebVisionModelUrlResolver modelUrlResolver;
  final StreamController<List<BaybayinDetection>> _detections =
      StreamController<List<BaybayinDetection>>.broadcast();
  final WebYoloOutputParser _parser = const WebYoloOutputParser(
    labels: kBaybayinWebYoloLabels,
    confidenceThreshold: 0.8,
    iouThreshold: 0.45,
    minBoxArea: 0.001,
    edgeMargin: 0.02,
  );

  TFLiteModel? _model;
  String? _loadedModelUrl;
  static Future<void>? _initializeTflite;

  @override
  Stream<List<BaybayinDetection>> get detections => _detections.stream;

  @override
  Future<List<BaybayinDetection>> detectImage(Uint8List imageBytes) async {
    final TFLiteModel model = await _loadModel();
    final List<int> inputShape = _inputShapeFor(model);
    final int inputWidth = _inputWidth(inputShape);
    final int inputHeight = _inputHeight(inputShape);
    final Tensor input = Tensor(
      _normalizeImage(imageBytes, width: inputWidth, height: inputHeight),
      shape: inputShape,
      type: TFLiteDataType.float32,
    );

    Tensor? outputTensor;
    try {
      final Tensor output = model.predict<Tensor>(input);
      outputTensor = output;
      final List<double> values = _tensorValues(output);
      final List<int>? outputShape = model.outputs.isEmpty
          ? null
          : model.outputs.first.shape;
      final List<BaybayinDetection> detections = _parser.parse(
        values,
        shape: outputShape,
      );
      if (!_detections.isClosed) {
        _detections.add(detections);
      }
      return detections;
    } finally {
      input.dispose();
      outputTensor?.dispose();
    }
  }

  Future<TFLiteModel> _loadModel() async {
    final String? modelUrl = await modelUrlResolver();
    if (modelUrl == null || modelUrl.trim().isEmpty) {
      throw StateError('No web scanner model URL is configured.');
    }

    if (_model != null && _loadedModelUrl == modelUrl) {
      return _model!;
    }

    _initializeTflite ??= TFLiteWeb.initializeUsingCDN();
    await _initializeTflite;
    await _validateModelUrl(modelUrl);
    _model = await TFLiteModel.fromUrl(
      modelUrl,
    ).timeout(const Duration(seconds: 25));
    _loadedModelUrl = modelUrl;
    return _model!;
  }

  Future<void> _validateModelUrl(String modelUrl) async {
    final Uri uri = Uri.parse(modelUrl);
    final http.Response response = await http
        .head(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 404) {
      throw StateError('Scanner model URL returned HTTP 404: $modelUrl');
    }
    if (response.statusCode >= 400) {
      throw StateError(
        'Scanner model URL returned HTTP ${response.statusCode}: $modelUrl',
      );
    }
  }

  List<int> _inputShapeFor(TFLiteModel model) {
    final List<int>? shape = model.inputs.isEmpty
        ? null
        : model.inputs.first.shape;
    if (shape == null || shape.length != 4) {
      return const <int>[1, 640, 640, 3];
    }
    return shape.map((int value) => value <= 0 ? 1 : value).toList();
  }

  int _inputWidth(List<int> shape) {
    if (shape[1] == 3) return shape[3];
    return shape[2];
  }

  int _inputHeight(List<int> shape) {
    if (shape[1] == 3) return shape[2];
    return shape[1];
  }

  Float32List _normalizeImage(
    Uint8List bytes, {
    required int width,
    required int height,
  }) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('The captured webcam frame could not be decoded.');
    }
    final img.Image resized = img.copyResize(
      img.bakeOrientation(decoded),
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );
    final Float32List input = Float32List(width * height * 3);
    int offset = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final img.Pixel pixel = resized.getPixel(x, y);
        input[offset++] = pixel.r / 255.0;
        input[offset++] = pixel.g / 255.0;
        input[offset++] = pixel.b / 255.0;
      }
    }
    return input;
  }

  List<double> _tensorValues(Tensor tensor) {
    final Object raw = tensor.dataSync<Object>();
    if (raw is Float32List) {
      return raw.toList(growable: false);
    }
    if (raw is Float64List) {
      return raw.toList(growable: false);
    }
    if (raw is Int32List) {
      return raw.map((int value) => value.toDouble()).toList(growable: false);
    }
    if (raw is List) {
      return raw
          .whereType<num>()
          .map((num value) => value.toDouble())
          .toList(growable: false);
    }
    throw StateError('The web scanner model returned an unreadable tensor.');
  }

  @override
  Future<void> toggleTorch({required bool enabled}) async {}

  @override
  Future<void> switchCamera() async {}

  @override
  void dispose() {
    _detections.close();
  }
}
