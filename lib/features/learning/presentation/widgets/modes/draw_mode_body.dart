import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/learn/live_stroke_painter.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_controller.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/lesson_state.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/reference_glyph_card.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
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
  final List<List<Offset>> _strokes = <List<Offset>>[];
  final List<List<Offset>> _undone = <List<Offset>>[];
  final List<Offset> _current = <Offset>[];
  bool _glyphVisible = true;
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
    final List<List<Offset>> snapshot = _strokes
        .map(List<Offset>.from)
        .toList(growable: false);
    ref.read(lessonControllerProvider.notifier).submitDraw(snapshot);
    return true;
  }

  void _onCameraDetections(List<BaybayinDetection> dets) {
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
    setState(() {
      _strokes.clear();
      _undone.clear();
      _current.clear();
    });
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
                ? _DrawCanvas(
                    status: widget.attemptStatus,
                    strokes: _strokes,
                    current: _current,
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
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
            label: widget.step.label,
            hideGlyph: widget.step.hideGlyph,
            visible: _glyphVisible,
            onToggle: () => setState(() => _glyphVisible = !_glyphVisible),
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
    required this.hideGlyph,
    required this.visible,
    required this.onToggle,
  });

  final String glyph;
  final String label;

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
          ReferenceGlyphCard(glyph: glyph, label: label, compact: true),
          Positioned(
            top: -6,
            right: -6,
            child: Tooltip(
              message: 'Hide reference',
              child: InkWell(
                onTap: onToggle,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.visibility_off_rounded,
                    size: 16,
                    color: cs.onSurface,
                  ),
                ),
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
