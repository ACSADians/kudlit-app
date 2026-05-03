import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/admin/data/services/stroke_export_service.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';
import 'package:kudlit_ph/features/admin/domain/entities/timed_point.dart';
import 'package:kudlit_ph/features/admin/presentation/providers/stroke_recording_notifier.dart';
import 'package:kudlit_ph/features/admin/presentation/providers/stroke_recording_state.dart';

/// Admin-only screen for recording Baybayin stroke patterns.
///
/// Shows a full-screen drawing canvas with the target glyph overlaid at low
/// opacity, a glyph-selector chip row, and undo / clear / save controls.
class StrokeRecordingScreen extends ConsumerWidget {
  const StrokeRecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StrokeRecordingState state =
        ref.watch(strokeRecordingNotifierProvider);

    return Scaffold(
      backgroundColor: KudlitColors.neutralBlack,
      appBar: AppBar(
        backgroundColor: KudlitColors.blue200,
        foregroundColor: KudlitColors.neutralWhite,
        title: const Text(
          'Stroke Recorder',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          if (state is StrokeRecordingIdle && state.hasStrokes)
            _UndoButton(state: state),
          if (state is StrokeRecordingIdle && state.hasStrokes)
            _ClearButton(state: state),
        ],
      ),
      body: switch (state) {
        StrokeRecordingSaved() => _SavedView(
            pattern: state.pattern,
            onNext: () =>
                ref.read(strokeRecordingNotifierProvider.notifier).resetAfterSave(),
          ),
        StrokeRecordingError() => _ErrorView(
            message: state.message,
            onDismiss: () =>
                ref.read(strokeRecordingNotifierProvider.notifier).dismissError(),
          ),
        _ => _RecordingBody(state: state),
      },
    );
  }
}

// ─── Main recording body ─────────────────────────────────────────────────────

class _RecordingBody extends ConsumerWidget {
  const _RecordingBody({required this.state});

  final StrokeRecordingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StrokeRecordingIdle? idle =
        state is StrokeRecordingIdle ? state as StrokeRecordingIdle : null;

    final String glyph = switch (state) {
      StrokeRecordingIdle(:final String selectedGlyph) => selectedGlyph,
      StrokeRecordingSaving(:final String selectedGlyph) => selectedGlyph,
      _ => kBaybayinGlyphs.first.glyph,
    };
    final String label = switch (state) {
      StrokeRecordingIdle(:final String selectedLabel) => selectedLabel,
      StrokeRecordingSaving(:final String selectedLabel) => selectedLabel,
      _ => kBaybayinGlyphs.first.label,
    };

    return Column(
      children: <Widget>[
        _GlyphSelector(
          selectedGlyph: glyph,
          onSelected: (String g, String l) =>
              ref.read(strokeRecordingNotifierProvider.notifier).selectGlyph(g, l),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _StrokeCountBadge(idle: idle),
                const SizedBox(height: 8),
                Expanded(
                  child: _DrawingCanvas(
                    idle: idle,
                    glyphChar: glyph,
                    isSaving: state is StrokeRecordingSaving,
                  ),
                ),
                const SizedBox(height: 16),
                _SaveButton(
                  idle: idle,
                  label: label,
                  isSaving: state is StrokeRecordingSaving,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glyph selector ──────────────────────────────────────────────────────────

class _GlyphSelector extends StatelessWidget {
  const _GlyphSelector({
    required this.selectedGlyph,
    required this.onSelected,
  });

  final String selectedGlyph;
  final void Function(String glyph, String label) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: KudlitColors.blue200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: kBaybayinGlyphs.length,
        separatorBuilder: (_, i) => const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int i) {
          final ({String glyph, String label}) item = kBaybayinGlyphs[i];
          final bool selected = item.glyph == selectedGlyph;
          return _GlyphChip(
            glyph: item.glyph,
            label: item.label,
            selected: selected,
            onTap: () => onSelected(item.glyph, item.label),
          );
        },
      ),
    );
  }
}

class _GlyphChip extends StatelessWidget {
  const _GlyphChip({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String glyph;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? KudlitColors.blue700 : KudlitColors.blue100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              glyph,
              style: TextStyle(
                fontFamily: 'Baybayin Simple TAWBID',
                fontSize: 18,
                color: selected
                    ? Colors.white
                    : KudlitColors.neutralWhite,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? Colors.white70
                    : KudlitColors.grey300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawing canvas ──────────────────────────────────────────────────────────

class _DrawingCanvas extends ConsumerStatefulWidget {
  const _DrawingCanvas({
    required this.idle,
    required this.glyphChar,
    required this.isSaving,
  });

  final StrokeRecordingIdle? idle;
  final String glyphChar;
  final bool isSaving;

  @override
  ConsumerState<_DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<_DrawingCanvas> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final StrokeRecordingIdle? idle = widget.idle;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        key: _canvasKey,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: KudlitColors.grey400,
            width: 1.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Reference glyph overlay — low opacity so it guides but doesn't
            // interfere with seeing the drawn strokes.
            Center(
              child: Text(
                widget.glyphChar,
                style: const TextStyle(
                  fontFamily: 'Baybayin Simple TAWBID',
                  fontSize: 220,
                  color: Color(0x18172F69),
                  height: 1,
                ),
              ),
            ),
            // Drawn strokes
            if (idle != null)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Size size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return CustomPaint(
                    painter: _TimedStrokePainter(
                      strokes: idle.strokes,
                      current: idle.currentStroke,
                      canvasSize: size,
                    ),
                    size: size,
                  );
                },
              ),
            // Gesture detector (disabled while saving)
            if (!widget.isSaving && idle != null)
              GestureDetector(
                onPanStart: (DragStartDetails d) {
                  final RenderBox? box = _canvasKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final Offset local = box.globalToLocal(d.globalPosition);
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanStart(local, box.size);
                },
                onPanUpdate: (DragUpdateDetails d) {
                  final RenderBox? box = _canvasKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final Offset local = box.globalToLocal(d.globalPosition);
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanUpdate(local, box.size);
                },
                onPanEnd: (_) {
                  final RenderBox? box = _canvasKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanEnd(box.size);
                },
              ),
            if (widget.isSaving)
              const Center(
                child: CircularProgressIndicator(
                  color: KudlitColors.blue700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Stroke painter ───────────────────────────────────────────────────────────

class _TimedStrokePainter extends CustomPainter {
  const _TimedStrokePainter({
    required this.strokes,
    required this.current,
    required this.canvasSize,
  });

  final List<StrokeData> strokes;
  final List<TimedPoint> current;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = KudlitColors.blue300
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final StrokeData stroke in strokes) {
      _drawPoints(canvas, stroke.points, size, paint);
    }

    if (current.length >= 2) {
      paint.color = KudlitColors.blue700;
      _drawPoints(canvas, current, size, paint);
    }
  }

  void _drawPoints(
    Canvas canvas,
    List<TimedPoint> points,
    Size size,
    Paint paint,
  ) {
    if (points.length < 2) return;
    final Path path = Path()
      ..moveTo(points[0].x * size.width, points[0].y * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x * size.width, points[i].y * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TimedStrokePainter old) => true;
}

// ─── Toolbar buttons ─────────────────────────────────────────────────────────

class _UndoButton extends ConsumerWidget {
  const _UndoButton({required this.state});

  final StrokeRecordingIdle state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.undo_rounded),
      tooltip: 'Undo last stroke',
      onPressed: () =>
          ref.read(strokeRecordingNotifierProvider.notifier).undoLastStroke(),
    );
  }
}

class _ClearButton extends ConsumerWidget {
  const _ClearButton({required this.state});

  final StrokeRecordingIdle state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded),
      tooltip: 'Clear all strokes',
      onPressed: () async {
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Clear strokes?'),
            content: const Text('This will remove all recorded strokes.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: KudlitColors.danger400),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          ref.read(strokeRecordingNotifierProvider.notifier).clearAll();
        }
      },
    );
  }
}

// ─── Stroke count badge ───────────────────────────────────────────────────────

class _StrokeCountBadge extends StatelessWidget {
  const _StrokeCountBadge({required this.idle});

  final StrokeRecordingIdle? idle;

  @override
  Widget build(BuildContext context) {
    final int count = idle?.strokes.length ?? 0;
    return Row(
      children: <Widget>[
        Icon(
          Icons.gesture_rounded,
          size: 14,
          color: KudlitColors.grey300,
        ),
        const SizedBox(width: 4),
        Text(
          '$count stroke${count == 1 ? '' : 's'} recorded',
          style: const TextStyle(
            fontSize: 12,
            color: KudlitColors.grey300,
          ),
        ),
        const Spacer(),
        const Text(
          'Draw the glyph — lift finger to end each stroke',
          style: TextStyle(
            fontSize: 11,
            color: KudlitColors.grey300,
          ),
        ),
      ],
    );
  }
}

// ─── Save button ─────────────────────────────────────────────────────────────

class _SaveButton extends ConsumerWidget {
  const _SaveButton({
    required this.idle,
    required this.label,
    required this.isSaving,
  });

  final StrokeRecordingIdle? idle;
  final String label;
  final bool isSaving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool canSave = idle != null && idle!.strokes.isNotEmpty && !isSaving;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: KudlitColors.blue700,
          disabledBackgroundColor: KudlitColors.blue100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canSave
            ? () async {
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                final Size size = box?.size ?? const Size(300, 300);
                await ref
                    .read(strokeRecordingNotifierProvider.notifier)
                    .save(size);
              }
            : null,
        icon: const Icon(Icons.save_alt_rounded, size: 18),
        label: Text(
          isSaving ? 'Saving…' : 'Save "$label" Pattern',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Saved confirmation ───────────────────────────────────────────────────────

class _SavedView extends StatefulWidget {
  const _SavedView({required this.pattern, required this.onNext});

  final StrokePattern pattern;
  final VoidCallback onNext;

  @override
  State<_SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<_SavedView> {
  bool _exporting = false;
  String? _exportedName;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final String name =
          await exportStrokePatternAsJson(widget.pattern);
      if (mounted) setState(() => _exportedName = name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: KudlitColors.success400,
            ),
            const SizedBox(height: 16),
            Text(
              '"${widget.pattern.label}" saved',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: KudlitColors.neutralWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.pattern.strokes.length} strokes · '
              '${widget.pattern.strokes.fold(0, (int s, StrokeData d) => s + d.points.length)} points',
              style: const TextStyle(
                fontSize: 13,
                color: KudlitColors.grey300,
              ),
            ),
            if (_exportedName != null) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: KudlitColors.success400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _exportedName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: KudlitColors.success400,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: KudlitColors.neutralWhite,
                side: const BorderSide(color: KudlitColors.blue600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _exporting ? null : _export,
              icon: _exporting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded, size: 16),
              label: Text(_exporting ? 'Exporting…' : 'Export as JSON'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KudlitColors.blue700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onNext,
              child: const Text('Record another'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: KudlitColors.danger400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Save failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KudlitColors.neutralWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: KudlitColors.grey300,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onDismiss,
              child: const Text('Back to drawing'),
            ),
          ],
        ),
      ),
    );
  }
}
