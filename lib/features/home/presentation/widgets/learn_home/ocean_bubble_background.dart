import 'dart:math' as math;

import 'package:flutter/material.dart';

class OceanBubbleBackground extends StatefulWidget {
  const OceanBubbleBackground({super.key});

  @override
  State<OceanBubbleBackground> createState() => _OceanBubbleBackgroundState();
}

class _OceanBubbleBackgroundState extends State<OceanBubbleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();
    final Color bubbleColor = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _BubblePainter(
            progress: _controller.value,
            baseColor: bubbleColor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.baseY,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.phase,
  });

  final double x;
  final double baseY;
  final double speed;
  final double radius;
  final double opacity;
  final double phase;
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.progress, required this.baseColor});

  final double progress;
  final Color baseColor;

  static final List<_Bubble> _bubbles = _generateBubbles();

  static List<_Bubble> _generateBubbles() {
    final math.Random rng = math.Random(42);
    return List<_Bubble>.generate(
      10,
      (int i) => _Bubble(
        x: rng.nextDouble(),
        baseY: rng.nextDouble(),
        speed: 0.22 + rng.nextDouble() * 0.42,
        radius: 5.0 + rng.nextDouble() * 14.0,
        opacity: 0.06 + rng.nextDouble() * 0.09,
        phase: rng.nextDouble() * math.pi * 2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final _Bubble b in _bubbles) {
      double yNorm = (b.baseY - progress * b.speed) % 1.0;
      if (yNorm < 0) yNorm += 1.0;
      final double drift =
          math.sin(progress * math.pi * 2 + b.phase) * 0.022;
      final double x = (b.x + drift).clamp(0.0, 1.0);
      final Offset center = Offset(x * size.width, yNorm * size.height);

      // Filled core — very faint
      canvas.drawCircle(
        center,
        b.radius,
        Paint()
          ..color = baseColor.withAlpha(((b.opacity * 0.35) * 255).round())
          ..style = PaintingStyle.fill,
      );
      // Stroke ring
      canvas.drawCircle(
        center,
        b.radius,
        Paint()
          ..color = baseColor.withAlpha((b.opacity * 255).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.baseColor != baseColor;
}
