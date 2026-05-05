import 'package:flutter/material.dart';

class BeginButton extends StatelessWidget {
  const BeginButton({
    super.key,
    required this.onStart,
    this.isLocked = false,
    this.label = 'Begin Lesson',
  });

  final VoidCallback onStart;
  final bool isLocked;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: GestureDetector(
        onTap: isLocked ? null : onStart,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isLocked ? cs.surfaceContainerHighest : cs.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLocked
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: cs.onSurface.withAlpha(100),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Complete the previous lesson',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
