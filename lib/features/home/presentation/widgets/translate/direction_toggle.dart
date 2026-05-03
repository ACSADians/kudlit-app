import 'package:flutter/material.dart';

import 'toggle_pill.dart';

class DirectionToggle extends StatelessWidget {
  const DirectionToggle({
    super.key,
    required this.latinToBaybayin,
    required this.onToggle,
  });

  final bool latinToBaybayin;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TogglePill(
                label: 'Filipino → Baybayin',
                active: latinToBaybayin,
                onTap: () => onToggle(true),
              ),
              TogglePill(
                label: 'Baybayin → Filipino',
                active: !latinToBaybayin,
                onTap: () => onToggle(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
