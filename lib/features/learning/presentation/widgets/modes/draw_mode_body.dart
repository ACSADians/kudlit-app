import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/learn/live_stroke_painter.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_controller.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/reference_glyph_card.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/scanner/presentation/widgets/scanner_camera.dart';

/// Where the learner's drawing comes from.
enum DrawInputSource { pen, camera }

/// Draw mode: top toolbar (undo / redo / clear), big canvas,
/// reference glyph chip below the canvas. The coach panel's OK button
/// handles submit + continue (no inline Check button).
class DrawModeBody extends ConsumerStatefulWidget {
  const DrawModeBody({
    super.key,
    required this.step,
    required this.attemptStatus,
  });

  final LessonStep step;
  final AttemptStatus attemptStatus;

  @override
  ConsumerState<DrawModeBody> createState() => DrawModeBodyState();
}

class DrawModeBodyState extends ConsumerState<DrawModeBody> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSubmitting = false;
  final List<List<Offset>> _strokes = <List<Offset>>[];
  final List<List<Offset>> _undone = <List<Offset>>[];
  final List<Offset> _current = <Offset>[];
  bool _glyphVisible = false;
  DrawInputSource _source = DrawInputSource.pen;

  /// Latest detection class name from the camera, lower-cased and trimmed.
  String? _lastCameraLabel;
  double? _lastCameraConfidence;

  @override
  void didUpdateWidget(covariant DrawModeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      setState(() {
        _strokes.clear();
        _undone.clear();
        _current.clear();
        _glyphVisible = false;
      });
    }
  }

  /// Called by the parent (via the coach panel's OK button) to submit.
  /// Returns false if there is nothing to submit yet.
  bool submitToController() {
    if (_source == DrawInputSource.camera) {
      final String? label = _lastCameraLabel;
      if (label == null || label.isEmpty) return false;
      // Camera detections are validated through the same path as text input:
      // the detected class name is checked against `step.expected`.
      ref.read(lessonControllerProvider.notifier).submitText(label);
      return true;
    }
    if (_strokes.isEmpty) return false;
    if (_isSubmitting) return false;
    _submitWithYolo();
    return true;
  }

  /// Captures the pen canvas as a PNG, runs YOLO inference, and submits the
  /// top detected label to [LessonController.submitDetection].
  ///
  /// Falls back to the stub [LessonController.submitDraw] when:
  ///   - running on web (no native YOLO)
  ///   - the model path is unavailable (not downloaded yet)
  ///   - inference throws an error
  Future<void> _submitWithYolo() async {
    _isSubmitting = true;
    final LessonController ctrl = ref.read(lessonControllerProvider.notifier);
    ctrl.startChecking();
    try {
      await _doYoloInference(ctrl);
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> _doYoloInference(LessonController ctrl) async {
    if (!kIsWeb) {
      final Uint8List? imageBytes = await _captureCanvas();
      if (imageBytes == null) {
        debugPrint('[DrawMode] canvas capture returned null — using stub');
      } else {
        try {
          // Use the pre-loaded instance — no cold-start on first sketch submit.
          final YOLO yolo = await ref.read(yoloDrawingPadModelProvider.future);
          debugPrint(
            '[DrawMode] running predict on ${imageBytes.lengthInBytes} bytes',
          );
          final Map<String, dynamic> result = await yolo.predict(
            imageBytes,
            confidenceThreshold: 0.25,
          );
          final List<dynamic> dets =
              result['detections'] as List<dynamic>? ?? <dynamic>[];
          debugPrint('[DrawMode] detections: ${dets.length}');
          if (dets.isNotEmpty) {
            YOLOResult? top;
            for (final dynamic d in dets) {
              final YOLOResult r = YOLOResult.fromMap(
                d as Map<dynamic, dynamic>,
              );
              debugPrint(
                '[DrawMode]   ${r.className} conf=${r.confidence.toStringAsFixed(2)}',
              );
              if (top == null || r.confidence > top.confidence) top = r;
            }
            if (top != null) {
              debugPrint(
                '[DrawMode] submitting top detection: ${top.className} '
                '(${top.confidence.toStringAsFixed(2)}) | '
                'expected: ${widget.step.expected}',
              );
              ctrl.submitDetection(top.className.trim().toLowerCase());
              return;
            }
          }
          // 0 detections or no valid top — fall through to Gemma visual
          // analysis so the user gets useful stroke feedback instead of a
          // silent retry.
          debugPrint('[DrawMode] no detections — handing off to Gemma');
        } catch (e) {
          debugPrint('[DrawMode] YOLO sketch inference failed: $e');
        }
      }
    }

    // Capture the canvas as PNG for Gemma image analysis (works on web too).
    final Uint8List? imageBytes = await _captureCanvas();

    // Only fall back to stub on web or if capture/model fails (not on 0 detections).
    debugPrint(
      '[DrawMode] falling back to submitDraw stub (capture or model error)',
    );
    final List<List<Offset>> snapshot = _strokes
        .map(List<Offset>.from)
        .toList(growable: false);
    await ctrl.submitDraw(snapshot, imageBytes: imageBytes);
  }

  /// Renders the strokes onto a white canvas with black ink and returns the
  /// result as a PNG [Uint8List].
  ///
  /// This is intentionally theme-agnostic: the YOLO model was trained on
  /// dark-ink-on-white images, so we always produce that regardless of the
  /// app's color scheme.
  Future<Uint8List?> _captureCanvas() async {
    try {
      const double pixelRatio = 2.0;
      final RenderBox box =
          _canvasKey.currentContext!.findRenderObject()! as RenderBox;
      final Size size = box.size;
      final int width = (size.width * pixelRatio).round();
      final int height = (size.height * pixelRatio).round();

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      );

      // White background — matches training data.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Black ink — always, regardless of theme.
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 3.5 * pixelRatio
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (final List<Offset> stroke in _strokes) {
        if (stroke.length < 2) continue;
        final Path path = Path()
          ..moveTo(stroke[0].dx * pixelRatio, stroke[0].dy * pixelRatio);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx * pixelRatio, stroke[i].dy * pixelRatio);
        }
        canvas.drawPath(path, strokePaint);
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(width, height);
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? bytes = data?.buffer.asUint8List();

      return bytes;
    } catch (e) {
      debugPrint('[DrawMode] Canvas capture failed: $e');
      return null;
    }
  }

  void _onCameraDetections(List<BaybayinDetection> dets) {
    _resetRetryIfNeeded();
    if (dets.isEmpty) {
      if (_lastCameraLabel != null) {
        setState(() {
          _lastCameraLabel = null;
          _lastCameraConfidence = null;
        });
      }
      return;
    }
    // Pick the highest-confidence detection.
    final BaybayinDetection top = dets.reduce(
      (BaybayinDetection a, BaybayinDetection b) =>
          a.confidence >= b.confidence ? a : b,
    );
    setState(() {
      _lastCameraLabel = top.label.trim().toLowerCase();
      _lastCameraConfidence = top.confidence;
    });
  }

  void _onPanStart(DragStartDetails d) {
    _resetRetryIfNeeded();
    setState(() {
      _current
        ..clear()
        ..add(d.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _current.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails _) {
    if (_current.isEmpty) return;
    setState(() {
      _strokes.add(List<Offset>.from(_current));
      _current.clear();
      _undone.clear();
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _undone.add(_strokes.removeLast()));
  }

  void _redo() {
    if (_undone.isEmpty) return;
    setState(() => _strokes.add(_undone.removeLast()));
  }

  void _clear() {
    _resetRetryIfNeeded();
    setState(() {
      _strokes.clear();
      _undone.clear();
      _current.clear();
    });
  }

  void _resetRetryIfNeeded() {
    if (widget.attemptStatus == AttemptStatus.retry) {
      ref.read(lessonControllerProvider.notifier).resetAttempt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SourceToggle(
            source: _source,
            onChanged: (DrawInputSource s) => setState(() => _source = s),
          ),
          const SizedBox(height: 8),
          if (_source == DrawInputSource.pen) ...<Widget>[
            _DrawToolbar(
              glyphVisible: _glyphVisible,
              onToggleGlyph: () =>
                  setState(() => _glyphVisible = !_glyphVisible),
              onUndo: _strokes.isEmpty ? null : _undo,
              onRedo: _undone.isEmpty ? null : _redo,
              onClear: _strokes.isEmpty ? null : _clear,
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: _source == DrawInputSource.pen
                ? RepaintBoundary(
                    key: _canvasKey,
                    child: _DrawCanvas(
                      status: widget.attemptStatus,
                      strokes: _strokes,
                      current: _current,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                    ),
                  )
                : _CameraCanvas(
                    status: widget.attemptStatus,
                    detectionLabel: _lastCameraLabel,
                    detectionConfidence: _lastCameraConfidence,
                    onDetections: _onCameraDetections,
                  ),
          ),
          const SizedBox(height: 12),
          _GlyphToggle(
            glyph: widget.step.glyph,
            glyphImage: widget.step.glyphImage,
            label: widget.step.label,
            hideGlyph: widget.step.hideGlyph,
            visible: _glyphVisible,
            onToggle: () => setState(() => _glyphVisible = !_glyphVisible),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed:
                widget.attemptStatus == AttemptStatus.checking ||
                    widget.attemptStatus == AttemptStatus.correct
                ? null
                : submitToController,
            icon: widget.attemptStatus == AttemptStatus.checking
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              widget.attemptStatus == AttemptStatus.checking
                  ? 'Checking drawing'
                  : 'Check drawing',
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({required this.source, required this.onChanged});

  final DrawInputSource source;
  final ValueChanged<DrawInputSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DrawInputSource>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<DrawInputSource>>[
        ButtonSegment<DrawInputSource>(
          value: DrawInputSource.pen,
          icon: Icon(Icons.edit_rounded, size: 18),
          label: Text('Sketch'),
        ),
        ButtonSegment<DrawInputSource>(
          value: DrawInputSource.camera,
          icon: Icon(Icons.photo_camera_rounded, size: 18),
          label: Text('Camera'),
        ),
      ],
      selected: <DrawInputSource>{source},
      onSelectionChanged: (Set<DrawInputSource> s) => onChanged(s.first),
    );
  }
}

class _CameraCanvas extends StatelessWidget {
  const _CameraCanvas({
    required this.status,
    required this.detectionLabel,
    required this.detectionConfidence,
    required this.onDetections,
  });

  final AttemptStatus status;
  final String? detectionLabel;
  final double? detectionConfidence;
  final void Function(List<BaybayinDetection>) onDetections;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color border;
    switch (status) {
      case AttemptStatus.correct:
        border = cs.primary;
      case AttemptStatus.retry:
        border = cs.error;
      case AttemptStatus.checking:
      case AttemptStatus.idle:
        border = cs.outlineVariant;
    }
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ScannerCamera(onDetections: onDetections),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _CameraReadout(
              label: detectionLabel,
              confidence: detectionConfidence,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraReadout extends StatelessWidget {
  const _CameraReadout({required this.label, required this.confidence});

  final String? label;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasDetection = label != null && label!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            hasDetection
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: hasDetection
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasDetection
                  ? 'Detected: ${label!.toUpperCase()} '
                        '(${((confidence ?? 0) * 100).round()}%)'
                  : 'Point your camera at a Baybayin character',
              style: text.bodyMedium?.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawToolbar extends StatelessWidget {
  const _DrawToolbar({
    required this.glyphVisible,
    required this.onToggleGlyph,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
  });

  final bool glyphVisible;
  final VoidCallback onToggleGlyph;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: onUndo,
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: onRedo,
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Redo',
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear',
          ),
          IconButton(
            onPressed: onToggleGlyph,
            icon: Icon(
              glyphVisible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
            tooltip: glyphVisible ? 'Hide reference' : 'Show reference',
          ),
        ],
      ),
    );
  }
}

class _DrawCanvas extends StatelessWidget {
  const _DrawCanvas({
    required this.status,
    required this.strokes,
    required this.current,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final AttemptStatus status;
  final List<List<Offset>> strokes;
  final List<Offset> current;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg;
    final Color border;
    final Color stroke;
    switch (status) {
      case AttemptStatus.correct:
        bg = cs.primaryContainer.withValues(alpha: 0.35);
        border = cs.primary;
        stroke = cs.primary;
      case AttemptStatus.retry:
        bg = cs.errorContainer.withValues(alpha: 0.35);
        border = cs.error;
        stroke = cs.error;
      case AttemptStatus.checking:
      case AttemptStatus.idle:
        bg = cs.surfaceContainerLowest;
        border = cs.outlineVariant;
        stroke = cs.onSurface;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: LiveStrokePainter(
            strokes: strokes,
            current: current,
            strokeColor: stroke,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Shows the compact reference glyph card when [visible], or a tappable
/// "Show reference" chip when hidden.
class _GlyphToggle extends StatelessWidget {
  const _GlyphToggle({
    required this.glyph,
    required this.label,
    this.glyphImage,
    required this.hideGlyph,
    required this.visible,
    required this.onToggle,
  });

  final String glyph;
  final String label;
  final String? glyphImage;

  /// If the step permanently hides the glyph (challenge mode), the toggle
  /// button is not shown — the learner can never reveal the answer.
  final bool hideGlyph;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    // Challenge step: glyph is always hidden, no toggle available.
    if (hideGlyph) {
      return ReferenceGlyphCard(
        glyph: glyph,
        glyphImage: glyphImage,
        label: label,
        compact: true,
        hideGlyph: true,
      );
    }
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: visible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Stack(
        alignment: Alignment.topRight,
        clipBehavior: Clip.none,
        children: <Widget>[
          ReferenceGlyphCard(
            glyph: glyph,
            glyphImage: glyphImage,
            label: label,
            compact: true,
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: cs.surfaceContainerHighest,
              shape: const CircleBorder(),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                onPressed: onToggle,
                icon: Icon(
                  Icons.visibility_off_rounded,
                  size: 16,
                  color: cs.onSurface,
                ),
                tooltip: 'Hide reference',
              ),
            ),
          ),
        ],
      ),
      secondChild: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onToggle,
          icon: const Icon(Icons.visibility_rounded, size: 18),
          label: Text('Show reference — $label'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: cs.outlineVariant),
          ),
        ),
      ),
    );
  }
}
