import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/model_not_ready_screen.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/yolo_sim_overlay.dart';

/// How often the detection output is forwarded to [ScannerCamera.onDetections].
/// The YOLO model keeps running every frame; only the UI updates are throttled.
const Duration _kDetectionInterval = Duration(milliseconds: 500);

/// Minimum confidence required for a detection to be surfaced.
/// Raised to 0.65 — the Baybayin model is domain-specific so anything below
/// this is almost certainly a false positive on non-Baybayin scenes.
const double _kConfidenceThreshold = 0.8;

/// IoU threshold for non-max suppression.
const double _kIoUThreshold = 0.45;

/// Minimum normalised bounding-box area (width × height in 0–1 space).
/// Boxes smaller than ~1.5 % of the frame are typically noise or partial hits.
const double _kMinBoxArea = 0.015;

/// How many consecutive throttle intervals a detection must appear before it
/// is surfaced to the UI. Prevents one-frame phantom detections.
const int _kRequiredConsecutiveHits = 2;

/// A self-contained camera widget with YOLO inference baked in.
///
/// Uses the keepAlive [baybayinDetectorProvider] so the model controller
/// is shared and survives tab switches — the splash screen pre-warms it
/// at startup to avoid first-load delay when the scan tab opens.
///
/// Detection output is throttled to once every [_kDetectionInterval] so the
/// overlay updates are visible without thrashing the widget tree.
///
/// On web shows a design-preview gradient; [onDetections] is never called.
class ScannerCamera extends ConsumerStatefulWidget {
  const ScannerCamera({
    required this.onDetections,
    this.flashOn = false,
    this.onFlashToggle,
    super.key,
  });

  /// Called at most once per [_kDetectionInterval] with the latest detections.
  final void Function(List<BaybayinDetection> detections) onDetections;

  /// Whether the torch is currently on. Ignored on web.
  final bool flashOn;

  /// Called when the user taps the flash icon. Null hides the icon.
  /// Always null on web.
  final VoidCallback? onFlashToggle;

  @override
  ConsumerState<ScannerCamera> createState() => _ScannerCameraState();
}

class _ScannerCameraState extends ConsumerState<ScannerCamera> {
  final Stopwatch _throttle = Stopwatch()..start();

  /// How many consecutive throttle intervals the current set of detections
  /// has been seen. Resets to 0 when a frame comes back empty.
  int _consecutiveHits = 0;

  void _onYoloResult(List<YOLOResult> results) {
    if (_throttle.elapsed < _kDetectionInterval) return;
    _throttle.reset();

    // 1. Confidence filter (native threshold should already handle this,
    //    but we double-check client-side).
    // 2. Minimum box area filter — eliminates tiny noise boxes.
    final List<YOLOResult> filtered = results.where((YOLOResult r) {
      if (r.confidence < _kConfidenceThreshold) return false;
      final double area = r.normalizedBox.width * r.normalizedBox.height;
      return area >= _kMinBoxArea;
    }).toList();

    if (filtered.isEmpty) {
      _consecutiveHits = 0;
      // Surface the empty list so the overlay clears immediately.
      _dispatch(filtered);
      return;
    }

    // 3. Temporal persistence — require N consecutive non-empty intervals
    //    before surfacing to the UI. Eliminates single-frame phantoms.
    _consecutiveHits++;
    debugPrint(
      '[ScannerCamera] ${filtered.length} hit(s) '
      '(consecutive: $_consecutiveHits/$_kRequiredConsecutiveHits)',
    );
    if (_consecutiveHits >= _kRequiredConsecutiveHits) {
      _dispatch(filtered);
    }
  }

  void _dispatch(List<YOLOResult> results) {
    final YoloBaybayinDetector detector =
        ref.read(baybayinDetectorProvider) as YoloBaybayinDetector;
    detector.onYoloResults(results);
    widget.onDetections(
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
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _WebCameraFallback();
    }

    // Resolve the active model for the camera scope, downloading on demand
    // when the catalog version is bumped or the user picks a different model.
    final AsyncValue<String> pathAsync = ref.watch(
      yoloModelPathProvider(YoloModelScope.camera),
    );
    return pathAsync.when(
      loading: () => const ModelNotReadyScreen(),
      error: (_, __) => const ModelNotReadyScreen(),
      data: (String modelPath) {
        final YoloBaybayinDetector detector =
            ref.watch(baybayinDetectorProvider) as YoloBaybayinDetector;
        debugPrint('[ScannerCamera] building YOLOView — modelPath: $modelPath');
        return YOLOView(
          modelPath: modelPath,
          task: YOLOTask.detect,
          controller: detector.controller,
          confidenceThreshold: _kConfidenceThreshold,
          iouThreshold: _kIoUThreshold,
          onResult: _onYoloResult,
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
