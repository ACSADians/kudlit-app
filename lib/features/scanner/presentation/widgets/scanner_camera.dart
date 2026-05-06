import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_baybayin_detector.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_tab_controller.dart';
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
typedef WebScannerCapture = Future<List<BaybayinDetection>> Function();
typedef WebScannerSwitchCamera = Future<void> Function();

enum WebScannerStatus {
  initializing,
  permissionNeeded,
  ready,
  detecting,
  modelUnavailable,
  error,
}

extension WebScannerStatusMeta on WebScannerStatus {
  String get label => switch (this) {
    WebScannerStatus.initializing => 'Allow camera',
    WebScannerStatus.permissionNeeded => 'Allow camera',
    WebScannerStatus.ready => 'Webcam ready',
    WebScannerStatus.detecting => 'Detecting',
    WebScannerStatus.modelUnavailable => 'Model unavailable',
    WebScannerStatus.error => 'Camera unavailable',
  };

  IconData get icon => switch (this) {
    WebScannerStatus.initializing => Icons.videocam_outlined,
    WebScannerStatus.permissionNeeded => Icons.no_photography_outlined,
    WebScannerStatus.ready => Icons.videocam_outlined,
    WebScannerStatus.detecting => Icons.center_focus_strong_rounded,
    WebScannerStatus.modelUnavailable => Icons.cloud_off_outlined,
    WebScannerStatus.error => Icons.error_outline_rounded,
  };
}

/// On web shows a real browser webcam preview and capture-based detection.
class ScannerCamera extends ConsumerStatefulWidget {
  const ScannerCamera({
    required this.onDetections,
    this.flashOn = false,
    this.onFlashToggle,
    this.onWebCaptureChanged,
    this.onWebSwitchCameraChanged,
    this.onWebStatusChanged,
    super.key,
  });

  /// Called at most once per [_kDetectionInterval] with the latest detections.
  final void Function(List<BaybayinDetection> detections) onDetections;

  /// Whether the torch is currently on. Ignored on web.
  final bool flashOn;

  /// Called when the user taps the flash icon. Null hides the icon.
  /// Always null on web.
  final VoidCallback? onFlashToggle;

  /// Provides the web-only capture function once the browser camera is ready.
  final ValueChanged<WebScannerCapture?>? onWebCaptureChanged;

  /// Provides a web-only switch-camera action when more than one camera exists.
  final ValueChanged<WebScannerSwitchCamera?>? onWebSwitchCameraChanged;

  /// Reports web-only camera/model state for the scan status chip.
  final ValueChanged<WebScannerStatus>? onWebStatusChanged;

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
      return _WebCameraPreview(
        onDetections: widget.onDetections,
        onCaptureChanged: widget.onWebCaptureChanged,
        onSwitchCameraChanged: widget.onWebSwitchCameraChanged,
        onStatusChanged: widget.onWebStatusChanged,
      );
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

// ── Web camera preview ───────────────────────────────────────────────────────

class _WebCameraPreview extends ConsumerStatefulWidget {
  const _WebCameraPreview({
    required this.onDetections,
    this.onCaptureChanged,
    this.onSwitchCameraChanged,
    this.onStatusChanged,
  });

  final void Function(List<BaybayinDetection>) onDetections;
  final ValueChanged<WebScannerCapture?>? onCaptureChanged;
  final ValueChanged<WebScannerSwitchCamera?>? onSwitchCameraChanged;
  final ValueChanged<WebScannerStatus>? onStatusChanged;

  @override
  ConsumerState<_WebCameraPreview> createState() => _WebCameraPreviewState();
}

class _WebCameraPreviewState extends ConsumerState<_WebCameraPreview> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const <CameraDescription>[];
  int _activeCameraIndex = 0;
  bool _switchingCamera = false;
  WebScannerStatus _status = WebScannerStatus.initializing;
  String? _message;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    widget.onCaptureChanged?.call(null);
    widget.onSwitchCameraChanged?.call(null);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    _setStatus(
      WebScannerStatus.initializing,
      message: 'Allow browser camera access to scan in web preview.',
    );
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        _setStatus(
          WebScannerStatus.error,
          message: 'No webcam was found. Use Gallery to test an image.',
        );
        return;
      }

      _cameras = cameras;
      _activeCameraIndex = _preferredCameraIndex(cameras);
      await _initializeCamera(cameras[_activeCameraIndex]);
    } on CameraException catch (e) {
      final bool denied =
          e.code == 'CameraAccessDenied' ||
          e.code == 'cameraPermission' ||
          e.description?.toLowerCase().contains('permission') == true;
      _setStatus(
        denied ? WebScannerStatus.permissionNeeded : WebScannerStatus.error,
        message: denied
            ? 'Camera permission is blocked. Allow camera access in the browser, then reload.'
            : 'Camera preview could not start. Use Gallery to test an image.',
      );
    } catch (_) {
      _setStatus(
        WebScannerStatus.error,
        message:
            'Camera preview could not start. Use Gallery to test an image.',
      );
    }
  }

  int _preferredCameraIndex(List<CameraDescription> cameras) {
    final int preferred = cameras.indexWhere(
      (CameraDescription c) =>
          c.lensDirection == CameraLensDirection.back ||
          c.lensDirection == CameraLensDirection.external,
    );
    return preferred == -1 ? 0 : preferred;
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    final CameraController controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }

    final CameraController? previous = _controller;
    _controller = controller;
    await previous?.dispose();

    widget.onCaptureChanged?.call(_captureAndDetect);
    widget.onSwitchCameraChanged?.call(
      _cameras.length > 1 ? _switchCamera : null,
    );
    _setStatus(WebScannerStatus.ready);
  }

  Future<void> _switchCamera() async {
    if (_switchingCamera || _cameras.length < 2) return;

    final int previousIndex = _activeCameraIndex;
    final int nextIndex = (_activeCameraIndex + 1) % _cameras.length;
    _switchingCamera = true;
    widget.onCaptureChanged?.call(null);
    widget.onSwitchCameraChanged?.call(null);
    _setStatus(WebScannerStatus.initializing, message: 'Switching camera...');

    try {
      await _initializeCamera(_cameras[nextIndex]);
      _activeCameraIndex = nextIndex;
    } catch (_) {
      _activeCameraIndex = previousIndex;
      if (_controller != null && _controller!.value.isInitialized) {
        widget.onCaptureChanged?.call(_captureAndDetect);
      }
      _setStatus(
        WebScannerStatus.error,
        message: 'Camera switch failed. Try again or use Gallery.',
      );
    } finally {
      _switchingCamera = false;
      if (mounted && _cameras.length > 1) {
        widget.onSwitchCameraChanged?.call(_switchCamera);
      }
    }
  }

  Future<List<BaybayinDetection>> _captureAndDetect() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _setStatus(
        WebScannerStatus.error,
        message: 'Camera is not ready yet. Try again in a moment.',
      );
      return const <BaybayinDetection>[];
    }

    _setStatus(WebScannerStatus.detecting);
    try {
      final XFile image = await controller.takePicture();
      final Uint8List bytes = await image.readAsBytes();
      final List<BaybayinDetection> detections = await ref
          .read(baybayinDetectorProvider)
          .detectImage(bytes);
      widget.onDetections(detections);
      _setStatus(WebScannerStatus.ready);
      return detections;
    } catch (e) {
      final ScanNotice notice = _noticeForCaptureError(e);
      _setStatus(
        notice.title == 'Web model unavailable'
            ? WebScannerStatus.modelUnavailable
            : WebScannerStatus.error,
        message: notice.message,
      );
      throw ScanCaptureException(notice);
    }
  }

  ScanNotice _noticeForCaptureError(Object error) {
    final String raw = error.toString().toLowerCase();
    if (raw.contains('404') ||
        raw.contains('not_found') ||
        raw.contains('object not found')) {
      return const ScanNotice(
        title: 'Web model unavailable',
        message:
            'The active scanner model file is missing from storage. Use Gallery for now or update the model URL.',
        kind: ScanNoticeKind.error,
      );
    }
    if (raw.contains('cors') || raw.contains('failed to fetch')) {
      return const ScanNotice(
        title: 'Web model unavailable',
        message:
            'The scanner model could not be loaded by the browser. Check CORS or the public model URL.',
        kind: ScanNoticeKind.error,
      );
    }
    if (raw.contains('tensor') || raw.contains('shape')) {
      return const ScanNotice(
        title: 'Model not compatible',
        message:
            'This model output does not match the web scanner parser. Use a YOLO TFLite model with the expected class order.',
        kind: ScanNoticeKind.error,
      );
    }
    if (raw.contains('model') || raw.contains('tflite')) {
      return const ScanNotice(
        title: 'Web model unavailable',
        message:
            'Webcam preview works, but the web scanner model could not run.',
        kind: ScanNoticeKind.error,
      );
    }
    return const ScanNotice(
      title: 'Capture failed',
      message: 'Try again or use Gallery to test an image.',
      kind: ScanNoticeKind.error,
    );
  }

  void _setStatus(WebScannerStatus status, {String? message}) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _message = message;
    });
    widget.onStatusChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: Colors.black.withAlpha(240)),
        if (_controller != null && _controller!.value.isInitialized)
          _CameraCover(controller: _controller!)
        else
          const YoloSimOverlay(),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding = constraints.maxWidth < 320
                ? 10
                : constraints.maxWidth < 380
                ? 14
                : 28;
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: WebStatusMessage(
                  cs: cs,
                  status: _status,
                  message: _message,
                  showCompact:
                      _controller != null && _controller!.value.isInitialized,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

@visibleForTesting
class WebStatusMessage extends StatelessWidget {
  const WebStatusMessage({
    required this.cs,
    required this.status,
    required this.showCompact,
    this.message,
    super.key,
  });

  final ColorScheme cs;
  final WebScannerStatus status;
  final String? message;
  final bool showCompact;

  @override
  Widget build(BuildContext context) {
    if (showCompact &&
        (status == WebScannerStatus.ready ||
            status == WebScannerStatus.modelUnavailable)) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 360;
        final double maxWidth = availableWidth.clamp(200.0, 240.0);
        final bool narrow = maxWidth < 300;

        return Semantics(
          label: message ?? status.label,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: showCompact
                    ? 12
                    : narrow
                    ? 12
                    : 16,
                vertical: showCompact
                    ? 12
                    : narrow
                    ? 14
                    : 16,
              ),
              decoration: BoxDecoration(
                color: cs.surface.withAlpha(showCompact ? 210 : 235),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    status.icon,
                    size: showCompact
                        ? 24
                        : narrow
                        ? 28
                        : 32,
                    color: cs.onSurface.withAlpha(190),
                  ),
                  SizedBox(height: showCompact || narrow ? 8 : 10),
                  Text(
                    status.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: showCompact
                          ? 14
                          : narrow
                          ? 15
                          : 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (message != null) const SizedBox(height: 6),
                  if (message != null)
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: showCompact || narrow ? 12.5 : 13,
                        height: 1.35,
                        color: cs.onSurface.withAlpha(165),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size? previewSize = controller.value.previewSize;
        if (previewSize == null) {
          return CameraPreview(controller);
        }
        final double previewAspect = previewSize.height / previewSize.width;
        final double boxAspect = constraints.maxWidth / constraints.maxHeight;
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        if (boxAspect > previewAspect) {
          height = width / previewAspect;
        } else {
          width = height * previewAspect;
        }
        return ClipRect(
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}
