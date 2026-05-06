import 'package:flutter/material.dart';

class BeginButton extends StatefulWidget {
  const BeginButton({
    super.key,
    required this.onStart,
    this.isLocked = false,
    this.label = 'Begin Lesson',
    this.lockedReason,
  });

  final VoidCallback onStart;
  final bool isLocked;
  final String label;
  final String? lockedReason;

  @override
  State<BeginButton> createState() => _BeginButtonState();
}

class _BeginButtonState extends State<BeginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Listener(
            onPointerDown: widget.isLocked
                ? null
                : (_) => setState(() => _pressed = true),
            onPointerUp: widget.isLocked
                ? null
                : (_) => setState(() => _pressed = false),
            onPointerCancel: widget.isLocked
                ? null
                : (_) => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: (_pressed && !widget.isLocked) ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              child: FilledButton.icon(
                onPressed: widget.isLocked ? null : widget.onStart,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  widget.isLocked
                      ? Icons.lock_rounded
                      : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(widget.isLocked ? 'Locked' : widget.label),
              ),
            ),
          ),
          if (widget.isLocked && widget.lockedReason != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              widget.lockedReason!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
