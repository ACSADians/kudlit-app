import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/model_not_ready_screen.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/yolo_sim_overlay.dart';

/// Whether the Baybayin model is bundled for the current platform.
/// - Android: `assets/models/baybayin_yolo.tflite` ✅ available
/// - iOS    : `assets/models/baybayin_yolo.mlpackage.zip` ✅ available
bool get _kModelAvailable => !kIsWeb;

/// Flutter asset path for the bundled model (per platform).
String get _kModelPath => Platform.isIOS
    ? 'assets/models/baybayin_yolo.mlpackage.zip'
    : 'assets/models/baybayin_yolo.tflite';

/// A self-contained camera widget with YOLO inference baked in.
///
/// Uses the keepAlive [baybayinDetectorProvider] so the model controller
/// is shared and survives tab switches — the splash screen pre-warms it
/// at startup to avoid first-load delay when the scan tab opens.
///
/// On web shows a design-preview gradient; [onDetections] is never called.
class ScannerCamera extends ConsumerWidget {
  const ScannerCamera({
    required this.onDetections,
    this.flashOn = false,
    this.onFlashToggle,
    super.key,
  });

  /// Called every time the model produces a new batch of detections.
  final void Function(List<BaybayinDetection> detections) onDetections;

  /// Whether the torch is currently on. Ignored on web.
  final bool flashOn;

  /// Called when the user taps the flash icon. Null hides the icon.
  /// Always null on web.
  final VoidCallback? onFlashToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return const _WebCameraFallback();
    }

    if (!_kModelAvailable) {
      return const ModelNotReadyScreen();
    }

    // Reads from the keepAlive provider — pre-warmed by SplashScreen.
    final YoloBaybayinDetector detector =
        ref.watch(baybayinDetectorProvider) as YoloBaybayinDetector;

    debugPrint('[ScannerCamera] building YOLOView — modelPath: $_kModelPath');
    return YOLOView(
      modelPath: _kModelPath,
      task: YOLOTask.detect,
      controller: detector.controller,
      onResult: (List<YOLOResult> results) {
        debugPrint(
          '[ScannerCamera] YOLOView.onResult: ${results.length} result(s)',
        );
        detector.onYoloResults(results);
        onDetections(
          results
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
              .toList(),
        );
      },
    );
  }
}

// ── Web fallback ──────────────────────────────────────────────────────────────

class _WebCameraFallback extends StatelessWidget {
  const _WebCameraFallback();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[cs.surfaceContainer, cs.surface],
            ),
          ),
        ),
        const YoloSimOverlay(),
      ],
    );
  }
}
