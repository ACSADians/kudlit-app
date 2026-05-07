import 'package:flutter/material.dart';

class TogglePill extends StatelessWidget {
  const TogglePill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? cs.onPrimary : cs.onSurface.withAlpha(140),
          ),
        ),
      ),
    );
  }
}
