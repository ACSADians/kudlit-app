import 'package:flutter/material.dart';

import 'toggle_pill.dart';

class DirectionToggle extends StatelessWidget {
  const DirectionToggle({
    super.key,
    required this.latinToBaybayin,
    required this.onToggle,
    this.compact = false,
  });

  final bool latinToBaybayin;
  final ValueChanged<bool> onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 390;
          final double toggleWidth = availableWidth < 390
              ? availableWidth
              : 390;
          return Center(
            child: SizedBox(
              width: toggleWidth,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TogglePill(
                        label: 'Filipino → Baybayin',
                        active: latinToBaybayin,
                        compact: compact,
                        onTap: () => onToggle(true),
                      ),
                    ),
                    Expanded(
                      child: TogglePill(
                        label: 'Baybayin → Filipino',
                        active: !latinToBaybayin,
                        compact: compact,
                        onTap: () => onToggle(false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
