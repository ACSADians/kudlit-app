import 'package:flutter/material.dart';

class PadButton extends StatelessWidget {
  const PadButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool active = onTap != null;
    Color bg;
    Color fg;
    if (!active) {
      bg = cs.surfaceContainerLow;
      fg = cs.onSurface.withAlpha(80);
    } else if (primary) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else {
      bg = cs.surfaceContainerHigh;
      fg = cs.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
