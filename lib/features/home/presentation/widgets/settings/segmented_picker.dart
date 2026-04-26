import 'package:flutter/material.dart';

class SegmentedPicker<T> extends StatelessWidget {
  const SegmentedPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map(((T, String) opt) {
          final bool active = opt.$1 == selected;
          return GestureDetector(
            onTap: () => onSelect(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                opt.$2,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? cs.onPrimary : cs.onSurface.withAlpha(102),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
