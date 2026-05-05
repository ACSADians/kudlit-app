import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// "Butty is thinking" indicator shown while waiting for the first token.
///
/// Uses flutter_animate (already in pubspec) for the wave/breathing effects
/// since rive is not installed. The avatar breathes, the bubble has a soft
/// shimmer, and the three dots wave with a staggered pulse.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _BreathingAvatar(background: cs.primaryContainer),
          const SizedBox(width: 8),
          _ShimmerBubble(
            background: cs.surfaceContainer,
            border: cs.outline,
            highlight: cs.primary.withAlpha(40),
            child: _WaveDots(color: cs.onSurface.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}

class _BreathingAvatar extends StatelessWidget {
  const _BreathingAvatar({required this.background});
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: ClipOval(
        child: Image.asset('assets/brand/ButtyRead.webp', fit: BoxFit.cover),
      ),
    )
        .animate(
          onPlay: (AnimationController c) => c.repeat(reverse: true),
        )
        .scaleXY(
          begin: 0.94,
          end: 1.04,
          duration: 1100.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _ShimmerBubble extends StatelessWidget {
  const _ShimmerBubble({
    required this.background,
    required this.border,
    required this.highlight,
    required this.child,
  });

  final Color background;
  final Color border;
  final Color highlight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            border: Border.all(color: border),
          ),
          child: child,
        )
        .animate(onPlay: (AnimationController c) => c.repeat())
        .shimmer(
          duration: 1600.ms,
          color: highlight,
          angle: 0.3,
        );
  }
}

class _WaveDots extends StatelessWidget {
  const _WaveDots({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _Dot(color: color, delayMs: 0),
        const SizedBox(width: 4),
        _Dot(color: color, delayMs: 160),
        const SizedBox(width: 4),
        _Dot(color: color, delayMs: 320),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.delayMs});
  final Color color;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(
          onPlay: (AnimationController c) => c.repeat(reverse: true),
          delay: Duration(milliseconds: delayMs),
        )
        .moveY(begin: 0, end: -4, duration: 540.ms, curve: Curves.easeInOut)
        .fadeIn(begin: 0.4, duration: 540.ms);
  }
}
