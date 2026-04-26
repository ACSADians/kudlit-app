import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/web_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/domain/repositories/baybayin_detector.dart';

part 'scanner_provider.g.dart';

/// Provides the correct [BaybayinDetector] for the current platform.
@Riverpod(keepAlive: true)
BaybayinDetector baybayinDetector(Ref ref) {
  final BaybayinDetector detector = kIsWeb
      ? WebBaybayinDetector()
      : YoloBaybayinDetector();
  ref.onDispose(detector.dispose);
  return detector;
}

/// Holds the latest list of detections pushed from [ScannerCamera].
/// Updated imperatively via [ScannerNotifier.update].
@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  @override
  List<BaybayinDetection> build() => const <BaybayinDetection>[];

  void update(List<BaybayinDetection> detections) {
    state = detections;
  }

  void clear() {
    state = const <BaybayinDetection>[];
  }
}
