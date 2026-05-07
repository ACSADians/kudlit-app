import 'package:kudlit_ph/features/scanner/data/datasources/web_baybayin_detector_stub.dart'
    if (dart.library.js_interop) 'package:kudlit_ph/features/scanner/data/datasources/web_tflite_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/web_vision_model_url_resolver.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

BaybayinDetector createWebBaybayinDetector({
  required WebVisionModelUrlResolver modelUrlResolver,
}) {
  return createPlatformWebBaybayinDetector(modelUrlResolver: modelUrlResolver);
}
