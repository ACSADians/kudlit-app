import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/model_not_ready_screen.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/model_not_supported_screen.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/yolo_sim_overlay.dart';

/// How often the detection output is forwarded to [ScannerCamera.onDetections].
/// The YOLO model keeps running every frame; only the UI updates are throttled.
const Duration _kDetectionInterval = Duration(milliseconds: 250);

/// Minimum confidence required for a detection to be surfaced.
/// 0.8 — conservative threshold suited to Baybayin's high inter-class visual
/// similarity (e.g., 'ba' vs 'da' strokes). Lower only after model retraining.
const double _kConfidenceThreshold = 0.8;

/// IoU threshold for non-max suppression.
const double _kIoUThreshold = 0.45;

/// Minimum normalised bounding-box area (width × height in 0–1 space).
/// Set very low so multi-character words can be detected when the user
/// frames a full phrase (each glyph then occupies only a small fraction
/// of the frame).
const double _kMinBoxArea = 0.001;

/// Detections whose box edge is within this margin (normalised) of the frame
/// edge are treated as partially out-of-view and dropped. Eliminates the
/// common case of half-visible neighbour glyphs being mis-classified.
const double _kEdgeMargin = 0.02;

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
/// On web shows an explicit no-camera fallback; [onDetections] is never called.
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

  String _modelErrorMessage(Object error) {
    final String raw = error.toString();
    if (raw.contains('No enabled')) {
      return 'No scanner model is configured yet.';
    }
    if (raw.contains('no download URL')) {
      return 'Model download URL is missing.';
    }
    if (raw.contains('no file is on disk')) {
      return 'Download may have been interrupted. Check your connection and retry.';
    }
    return 'Could not load the scanner model. Check your connection and retry.';
  }

  void _onYoloResult(List<YOLOResult> results) {
    if (_throttle.elapsed < _kDetectionInterval) return;
    _throttle.reset();

    // 1. Confidence filter (native threshold should already handle this,
    //    but we double-check client-side).
    // 2. Minimum box area filter — eliminates tiny noise boxes.
    // 3. In-frame filter — drop detections that are clipped by the frame
    //    edge (commonly mis-classified partial glyphs from neighbouring
    //    characters that are halfway out of view).
    final List<YOLOResult> filtered = results.where((YOLOResult r) {
      if (r.confidence < _kConfidenceThreshold) return false;
      final Rect b = r.normalizedBox;
      final double area = b.width * b.height;
      if (area < _kMinBoxArea) return false;
      // Reject if the box hugs / crosses the frame edge.
      const double edge = _kEdgeMargin;
      if (b.left < edge ||
          b.top < edge ||
          b.right > 1 - edge ||
          b.bottom > 1 - edge) {
        return false;
      }
      return true;
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

    final bool capable = ref.watch(deviceInferenceCapableProvider);
    if (!capable) {
      return const ModelNotSupportedScreen();
    }

    // Resolve the active model for the camera scope, downloading on demand
    // when the catalog version is bumped or the user picks a different model.
    final AsyncValue<String> pathAsync = ref.watch(
      yoloModelPathProvider(YoloModelScope.camera),
    );
    return pathAsync.when(
      loading: () => const ModelNotReadyScreen(),
      error: (Object error, StackTrace _) => ModelNotReadyScreen.error(
        errorMessage: _modelErrorMessage(error),
        onRetry: () =>
            ref.invalidate(yoloModelPathProvider(YoloModelScope.camera)),
      ),
      data: (String modelPath) {
        final YoloBaybayinDetector detector =
            ref.watch(baybayinDetectorProvider) as YoloBaybayinDetector;
        return YOLOView(
          modelPath: modelPath,
          task: YOLOTask.detect,
          controller: detector.controller,
          confidenceThreshold: _kConfidenceThreshold,
          iouThreshold: _kIoUThreshold,
          showOverlays: false,
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
        ColoredBox(color: cs.surfaceContainerLow),
        const YoloSimOverlay(),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _WebFallbackMessage(cs: cs),
          ),
        ),
      ],
    );
  }
}

class _WebFallbackMessage extends StatelessWidget {
  const _WebFallbackMessage({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Camera preview is unavailable on web. Use Gallery to test an image.',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withAlpha(235),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.photo_library_outlined,
              size: 32,
              color: cs.onSurface.withAlpha(190),
            ),
            const SizedBox(height: 10),
            Text(
              'Web Camera Preview Unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use Gallery to upload a Baybayin image while testing in the browser.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: cs.onSurface.withAlpha(165),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
