import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_stroke.dart';

class StrokeOrderSheet extends StatefulWidget {
  const StrokeOrderSheet({
    super.key,
    required this.glyph,
    required this.label,
    required this.data,
  });

  final String glyph;
  final String label;
  final StrokeOrderData data;

  @override
  State<StrokeOrderSheet> createState() => _StrokeOrderSheetState();
}

class _StrokeOrderSheetState extends State<StrokeOrderSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _playing = true;

  static const int _msPerStroke = 1200;
  static const int _pauseBetweenLoopsMs = 1000;

  @override
  void initState() {
    super.initState();
    final int totalMs = widget.data.strokes.length * _msPerStroke;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs.clamp(400, 8000)),
    );
    _ctrl.addStatusListener(_onStatus);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future<void>.delayed(
        const Duration(milliseconds: _pauseBetweenLoopsMs),
        () {
          if (mounted && _playing) _ctrl.forward(from: 0);
        },
      );
    }
  }

  void _togglePlayback() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _ctrl.forward(from: _ctrl.value < 1.0 ? _ctrl.value : 0.0);
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Semantics(
      namesRoute: true,
      label: '${widget.label} stroke order',
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const _SheetHandle(),
            const SizedBox(height: 16),
            _StrokeSheetTitle(
              glyph: widget.glyph,
              label: widget.label,
              strokeCount: widget.data.strokes.length,
            ),
            const SizedBox(height: 16),
            _StrokeCanvas(controller: _ctrl, data: widget.data),
            const SizedBox(height: 12),
            _StrokeControls(
              playing: _playing,
              onRestart: () {
                _ctrl.forward(from: 0);
                if (!_playing) setState(() => _playing = true);
              },
              onTogglePlayback: _togglePlayback,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: cs.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StrokeSheetTitle extends StatelessWidget {
  const _StrokeSheetTitle({
    required this.glyph,
    required this.label,
    required this.strokeCount,
  });

  final String glyph;
  final String label;
  final int strokeCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Text(
          glyph,
          style: const TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 36,
            height: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Stroke order',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: text.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$strokeCount stroke${strokeCount == 1 ? '' : 's'}',
          style: text.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close stroke order',
        ),
      ],
    );
  }
}

class _StrokeCanvas extends StatelessWidget {
  const _StrokeCanvas({required this.controller, required this.data});

  final AnimationController controller;
  final StrokeOrderData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? _) {
            final double progress = controller.value * data.strokes.length;
            return Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _StrokeOrderPainter(
                    strokes: data.strokes,
                    progress: progress,
                    completedColor: cs.primary,
                    activeColor: cs.tertiary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StrokeControls extends StatelessWidget {
  const _StrokeControls({
    required this.playing,
    required this.onRestart,
    required this.onTogglePlayback,
  });

  final bool playing;
  final VoidCallback onRestart;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: onRestart,
          icon: const Icon(Icons.replay_rounded),
          tooltip: 'Restart stroke order',
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
          onPressed: onTogglePlayback,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(playing ? 'Pause' : 'Play'),
        ),
      ],
    );
  }
}

class _StrokeOrderPainter extends CustomPainter {
  const _StrokeOrderPainter({
    required this.strokes,
    required this.progress,
    required this.completedColor,
    required this.activeColor,
  });

  final List<GlyphStroke> strokes;
  final double progress;
  final Color completedColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    final int fullyDone = progress.floor().clamp(0, strokes.length);
    final double activeFrac = progress - fullyDone;

    for (int i = 0; i < fullyDone; i++) {
      _drawStroke(canvas, size, strokes[i], 1.0, completedColor);
      _drawStartBadge(canvas, size, strokes[i], i + 1, completedColor);
    }

    if (fullyDone < strokes.length && activeFrac > 0) {
      _drawStroke(canvas, size, strokes[fullyDone], activeFrac, activeColor);
      _drawStartBadge(
        canvas,
        size,
        strokes[fullyDone],
        fullyDone + 1,
        activeColor,
      );
    }
  }

  void _drawStroke(
    Canvas canvas,
    Size size,
    GlyphStroke stroke,
    double frac,
    Color color,
  ) {
    final List<GlyphPoint> pts = stroke.points;
    if (pts.isEmpty) return;

    final int count = (pts.length * frac).round().clamp(1, pts.length);
    if (count < 2) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(pts[0].x * size.width, pts[0].y * size.height);
    for (int i = 1; i < count; i++) {
      path.lineTo(pts[i].x * size.width, pts[i].y * size.height);
    }
    canvas.drawPath(path, paint);
  }

  void _drawStartBadge(
    Canvas canvas,
    Size size,
    GlyphStroke stroke,
    int number,
    Color color,
  ) {
    if (stroke.points.isEmpty) return;
    final Offset center = Offset(
      stroke.points.first.x * size.width,
      stroke.points.first.y * size.height,
    );
    const double r = 10;

    canvas.drawCircle(center, r, Paint()..color = color);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_StrokeOrderPainter old) =>
      old.progress != progress ||
      old.strokes != strokes ||
      old.completedColor != completedColor ||
      old.activeColor != activeColor;
}
