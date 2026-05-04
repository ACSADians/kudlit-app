import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/admin/data/services/stroke_export_service.dart';
import 'package:kudlit_ph/features/admin/domain/entities/stroke_pattern.dart';
import 'package:kudlit_ph/features/admin/domain/entities/timed_point.dart';
import 'package:kudlit_ph/features/admin/presentation/providers/stroke_recording_notifier.dart';
import 'package:kudlit_ph/features/admin/presentation/providers/stroke_recording_state.dart';

/// Admin-only screen for recording Baybayin stroke patterns.
class StrokeRecordingScreen extends ConsumerWidget {
  const StrokeRecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StrokeRecordingState state = ref.watch(
      strokeRecordingNotifierProvider,
    );

    final StrokeRecordingIdle? idle = state is StrokeRecordingIdle
        ? state
        : null;

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
          if (idle != null && idle.hasStrokes) _UndoButton(state: idle),
          if (idle != null && idle.hasStrokes) _ClearButton(state: idle),
        ],
      ),
      body: switch (state) {
        StrokeRecordingSaved() => _SavedView(
          pattern: state.pattern,
          sessionPatterns: state.sessionPatterns,
          onNext: () => ref
              .read(strokeRecordingNotifierProvider.notifier)
              .resetAfterSave(),
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

class _RecordingBody extends StatelessWidget {
  const _RecordingBody({required this.state});

  final StrokeRecordingState state;

  @override
  Widget build(BuildContext context) {
    final StrokeRecordingIdle? idle = state is StrokeRecordingIdle
        ? state as StrokeRecordingIdle
        : null;

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

    final List<StrokePattern> sessionPatterns =
        idle?.sessionPatterns ?? const <StrokePattern>[];

    return Column(
      children: <Widget>[
        _ControlsBar(
          selectedGlyph: glyph,
          hasOverlay: idle?.overlayImageBytes != null,
        ),
        if (sessionPatterns.isNotEmpty)
          _SessionSavedStrip(patterns: sessionPatterns),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: <Widget>[
                _StrokeCountBadge(idle: idle),
                const SizedBox(height: 8),
                Expanded(
                  child: _DrawingCanvas(
                    idle: idle,
                    glyphChar: glyph,
                    overlayImageBytes: idle?.overlayImageBytes,
                    strokeWidth: idle?.strokeWidth ?? 4.0,
                    isSaving: state is StrokeRecordingSaving,
                  ),
                ),
                const SizedBox(height: 12),
                _ThicknessSlider(strokeWidth: idle?.strokeWidth ?? 4.0),
                const SizedBox(height: 8),
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

// ─── Controls bar (glyph dropdown + overlay picker) ───────────────────────────

class _ControlsBar extends ConsumerWidget {
  const _ControlsBar({required this.selectedGlyph, required this.hasOverlay});

  final String selectedGlyph;
  final bool hasOverlay;

  Future<void> _pickImage(WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;
    final Uint8List bytes = await picked.readAsBytes();
    ref.read(strokeRecordingNotifierProvider.notifier).setOverlayImage(bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 52,
      color: KudlitColors.blue200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _GlyphDropdown(
              selectedGlyph: selectedGlyph,
              onSelected: (String g, String l) => ref
                  .read(strokeRecordingNotifierProvider.notifier)
                  .selectGlyph(g, l),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _pickImage(ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasOverlay
                    ? KudlitColors.blue700.withAlpha(160)
                    : KudlitColors.blue100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    hasOverlay
                        ? Icons.image_rounded
                        : Icons.add_photo_alternate_outlined,
                    size: 16,
                    color: KudlitColors.neutralWhite,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasOverlay ? 'Image ✓' : 'Overlay',
                    style: const TextStyle(
                      fontSize: 11,
                      color: KudlitColors.neutralWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasOverlay) ...<Widget>[
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 16,
                color: KudlitColors.grey300,
              ),
              tooltip: 'Remove overlay',
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              onPressed: () => ref
                  .read(strokeRecordingNotifierProvider.notifier)
                  .setOverlayImage(null),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Glyph dropdown ──────────────────────────────────────────────────────────

class _GlyphDropdown extends StatelessWidget {
  const _GlyphDropdown({required this.selectedGlyph, required this.onSelected});

  final String selectedGlyph;
  final void Function(String glyph, String label) onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedGlyph,
        isDense: true,
        dropdownColor: KudlitColors.blue300,
        iconEnabledColor: KudlitColors.neutralWhite,
        selectedItemBuilder: (BuildContext context) {
          return kBaybayinGlyphs
              .map(
                (({String glyph, String label}) item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.glyph,
                      style: const TextStyle(
                        fontFamily: 'Baybayin Simple TAWBID',
                        fontSize: 22,
                        color: KudlitColors.neutralWhite,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KudlitColors.neutralWhite,
                      ),
                    ),
                  ],
                ),
              )
              .toList();
        },
        items: kBaybayinGlyphs
            .map(
              (({String glyph, String label}) item) => DropdownMenuItem<String>(
                value: item.glyph,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 32,
                      child: Text(
                        item.glyph,
                        style: const TextStyle(
                          fontFamily: 'Baybayin Simple TAWBID',
                          fontSize: 20,
                          color: KudlitColors.neutralWhite,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KudlitColors.neutralWhite,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (String? value) {
          if (value == null) return;
          final ({String glyph, String label}) item = kBaybayinGlyphs
              .firstWhere((e) => e.glyph == value);
          onSelected(item.glyph, item.label);
        },
      ),
    );
  }
}

// ─── Session saved strip ──────────────────────────────────────────────────────

class _SessionSavedStrip extends StatelessWidget {
  const _SessionSavedStrip({required this.patterns});

  final List<StrokePattern> patterns;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: KudlitColors.blue300.withAlpha(40),
      child: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: KudlitColors.grey300,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: patterns.length,
              separatorBuilder: (_, i) => const SizedBox(width: 6),
              itemBuilder: (BuildContext context, int i) =>
                  _SessionPatternChip(pattern: patterns[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionPatternChip extends StatelessWidget {
  const _SessionPatternChip({required this.pattern});

  final StrokePattern pattern;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KudlitColors.success400.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KudlitColors.success400.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            pattern.glyph,
            style: const TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: 16,
              color: KudlitColors.success400,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                pattern.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: KudlitColors.success400,
                ),
              ),
              Text(
                '${pattern.strokes.length}s',
                style: const TextStyle(
                  fontSize: 9,
                  color: KudlitColors.grey300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Thickness slider ─────────────────────────────────────────────────────────

class _ThicknessSlider extends ConsumerWidget {
  const _ThicknessSlider({required this.strokeWidth});

  final double strokeWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        const Icon(Icons.brush_rounded, size: 14, color: KudlitColors.grey300),
        const SizedBox(width: 6),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: KudlitColors.blue700,
              inactiveTrackColor: KudlitColors.blue100,
              thumbColor: KudlitColors.blue700,
              overlayColor: KudlitColors.blue700.withAlpha(30),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: strokeWidth,
              min: 2,
              max: 16,
              divisions: 14,
              onChanged: (double v) => ref
                  .read(strokeRecordingNotifierProvider.notifier)
                  .setStrokeWidth(v),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: Container(
              width: strokeWidth.clamp(2.0, 16.0),
              height: strokeWidth.clamp(2.0, 16.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: KudlitColors.blue700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Drawing canvas ───────────────────────────────────────────────────────────

class _DrawingCanvas extends ConsumerStatefulWidget {
  const _DrawingCanvas({
    required this.idle,
    required this.glyphChar,
    required this.overlayImageBytes,
    required this.strokeWidth,
    required this.isSaving,
  });

  final StrokeRecordingIdle? idle;
  final String glyphChar;
  final Uint8List? overlayImageBytes;
  final double strokeWidth;
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
          border: Border.all(color: KudlitColors.grey400, width: 1.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Reference overlay — custom image or Baybayin glyph text.
            if (widget.overlayImageBytes != null)
              Opacity(
                opacity: 0.15,
                child: Image.memory(
                  widget.overlayImageBytes!,
                  fit: BoxFit.contain,
                ),
              )
            else
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
                      strokeWidth: widget.strokeWidth,
                    ),
                    size: size,
                  );
                },
              ),
            // Gesture detector (disabled while saving)
            if (!widget.isSaving && idle != null)
              GestureDetector(
                onPanStart: (DragStartDetails d) {
                  final RenderBox? box =
                      _canvasKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (box == null) return;
                  final Offset local = box.globalToLocal(d.globalPosition);
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanStart(local, box.size);
                },
                onPanUpdate: (DragUpdateDetails d) {
                  final RenderBox? box =
                      _canvasKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (box == null) return;
                  final Offset local = box.globalToLocal(d.globalPosition);
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanUpdate(local, box.size);
                },
                onPanEnd: (_) {
                  final RenderBox? box =
                      _canvasKey.currentContext?.findRenderObject()
                          as RenderBox?;
                  if (box == null) return;
                  ref
                      .read(strokeRecordingNotifierProvider.notifier)
                      .onPanEnd(box.size);
                },
              ),
            if (widget.isSaving)
              const Center(
                child: CircularProgressIndicator(color: KudlitColors.blue700),
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
    required this.strokeWidth,
  });

  final List<StrokeData> strokes;
  final List<TimedPoint> current;
  final Size canvasSize;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = KudlitColors.blue300
      ..strokeWidth = strokeWidth
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
  bool shouldRepaint(_TimedStrokePainter old) =>
      old.strokes != strokes ||
      old.current != current ||
      old.strokeWidth != strokeWidth;
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
        const Icon(
          Icons.gesture_rounded,
          size: 14,
          color: KudlitColors.grey300,
        ),
        const SizedBox(width: 4),
        Text(
          '$count stroke${count == 1 ? '' : 's'} recorded',
          style: const TextStyle(fontSize: 12, color: KudlitColors.grey300),
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
  const _SavedView({
    required this.pattern,
    required this.sessionPatterns,
    required this.onNext,
  });

  final StrokePattern pattern;
  final List<StrokePattern> sessionPatterns;
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
      final String name = await exportStrokePatternAsJson(widget.pattern);
      if (mounted) setState(() => _exportedName = name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.sessionPatterns.isNotEmpty)
          _SessionSavedStrip(patterns: widget.sessionPatterns),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
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
              style: const TextStyle(fontSize: 13, color: KudlitColors.grey300),
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
