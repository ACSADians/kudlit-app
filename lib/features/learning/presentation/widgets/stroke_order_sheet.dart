import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_stroke.dart';

/// Bottom sheet that animates the stroke order for a Baybayin glyph.
///
/// Each stroke is drawn sequentially at a fixed pace. The animation loops
/// after a short pause so the learner can study it repeatedly.
class StrokeOrderSheet extends StatefulWidget {
  const StrokeOrderSheet({
    super.key,
    required this.glyph,
    required this.label,
    required this.strokes,
  });

  final String glyph;
  final String label;
  final List<GlyphStroke> strokes;

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
    final int totalMs = widget.strokes.length * _msPerStroke;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs.clamp(400, 8000)),
    );
    _ctrl.addStatusListener(_onStatus);
    Future<void>.delayed(
      const Duration(milliseconds: 200),
      () { if (mounted) _ctrl.forward(); },
    );
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
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: <Widget>[
              Text(
                widget.glyph,
                style: const TextStyle(
                  fontFamily: 'Baybayin Simple TAWBID',
                  fontSize: 36,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Stroke order',
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    widget.label,
                    style: text.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${widget.strokes.length} stroke${widget.strokes.length == 1 ? '' : 's'}',
                style: text.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Canvas
          AnimatedBuilder(
            animation: _ctrl,
            builder: (BuildContext context, Widget? _) {
              final double progress =
                  _ctrl.value * widget.strokes.length;
              return Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: _StrokeOrderPainter(
                      strokes: widget.strokes,
                      progress: progress,
                      completedColor: cs.primary,
                      activeColor: cs.tertiary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Restart
              IconButton(
                onPressed: () {
                  _ctrl.forward(from: 0);
                  if (!_playing) setState(() => _playing = true);
                },
                icon: const Icon(Icons.replay_rounded),
                tooltip: 'Restart',
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                onPressed: _togglePlayback,
                icon: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(_playing ? 'Pause' : 'Play'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _StrokeOrderPainter extends CustomPainter {
  const _StrokeOrderPainter({
    required this.strokes,
    required this.progress,
    required this.completedColor,
    required this.activeColor,
  });

  final List<GlyphStroke> strokes;

  /// Ranges from 0.0 (nothing drawn) to strokes.length (all drawn).
  final double progress;

  final Color completedColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    final int fullyDone = progress.floor().clamp(0, strokes.length);
    final double activeFrac = progress - fullyDone;

    // Draw completed strokes in primary color with stroke number badge.
    for (int i = 0; i < fullyDone; i++) {
      _drawStroke(canvas, size, strokes[i], 1.0, completedColor);
      _drawStartBadge(canvas, size, strokes[i], i + 1, completedColor);
    }

    // Draw the currently animating stroke.
    if (fullyDone < strokes.length && activeFrac > 0) {
      _drawStroke(canvas, size, strokes[fullyDone], activeFrac, activeColor);
      _drawStartBadge(canvas, size, strokes[fullyDone], fullyDone + 1, activeColor);
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

  /// Draws a small numbered circle at the start point of [stroke].
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
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_StrokeOrderPainter old) =>
      old.progress != progress ||
      old.strokes != strokes ||
      old.completedColor != completedColor ||
      old.activeColor != activeColor;
}
