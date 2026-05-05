import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ButtyBubble extends StatelessWidget {
  const ButtyBubble({
    super.key,
    required this.text,
    this.isStreaming = false,
  });

  final String text;

  /// True when this bubble is the active streaming response. Drives the
  /// trailing cursor that blinks until the stream closes.
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/brand/ButtyRead.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border.all(color: cs.outline),
              ),
              child: _BubbleContent(text: text, isStreaming: isStreaming),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({required this.text, required this.isStreaming});

  final String text;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle baseStyle = TextStyle(
      fontSize: 13.5,
      color: cs.onSurface.withAlpha(220),
      height: 1.5,
    );

    final Widget body = MarkdownBody(
      data: text,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        h1: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        h2: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        h3: baseStyle.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700),
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        listBullet: baseStyle,
        a: baseStyle.copyWith(
          color: cs.primary,
          decoration: TextDecoration.underline,
        ),
        code: baseStyle.copyWith(
          fontFamily: 'monospace',
          fontSize: 12.5,
          backgroundColor: cs.surface,
        ),
        codeblockDecoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: cs.primary, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 10),
        blockSpacing: 6,
      ),
    );

    if (!isStreaming) return body;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(child: body),
        const SizedBox(width: 2),
        _StreamingCursor(color: cs.primary),
      ],
    );
  }
}

class _StreamingCursor extends StatelessWidget {
  const _StreamingCursor({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        width: 6,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      )
          .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .fadeOut(duration: 600.ms, curve: Curves.easeInOut),
    );
  }
}
