import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';

part 'yolo_model_path_provider.g.dart';

/// Resolves the effective YOLO model path from the local download cache.
///
/// Returns an error state if the model has not been downloaded yet; the scanner
/// UI shows [ModelNotReadyScreen] in that case.
///
/// Kept alive so the file-system check runs only once per app session.
/// Re-read after a successful download via
/// `ref.invalidate(yoloModelPathProvider)`.
@Riverpod(keepAlive: true)
Future<String> yoloModelPath(Ref ref) async {
  if (kIsWeb) {
    // Web has no filesystem — asset path is never actually used for YOLOView
    // (the web camera fallback widget short-circuits before reaching this).
    return '';
  }
  return YoloModelCache.instance.resolvedModelPath();
}
