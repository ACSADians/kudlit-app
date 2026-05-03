import 'package:flutter/material.dart';

class DrawButton extends StatelessWidget {
  const DrawButton({
    super.key,
    required this.onTap,
    required this.processing,
    required this.done,
  });

  final VoidCallback? onTap;
  final bool processing;
  final bool done;

  String get _label {
    if (done) return 'Lesson complete';
    if (processing) return 'Butty is reviewing...';
    return 'Write in Baybayin';
  }

  IconData get _icon {
    if (done) return Icons.check_circle_outline;
    if (processing) return Icons.hourglass_top_rounded;
    return Icons.draw_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool active = onTap != null;
    final Color fg = active ? cs.onPrimary : cs.onSurface.withAlpha(80);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(_icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              _label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
