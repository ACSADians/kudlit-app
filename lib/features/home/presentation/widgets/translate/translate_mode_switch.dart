import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';

class TranslateModeSwitch extends StatelessWidget {
  const TranslateModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
    this.compact = false,
    this.tabletDensity = false,
  });

  final TranslateWorkspaceMode mode;
  final ValueChanged<TranslateWorkspaceMode> onChanged;
  final bool compact;
  final bool tabletDensity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: tabletDensity
          ? const EdgeInsets.all(4)
          : const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ModePill(
            label: 'Text',
            active: mode == TranslateWorkspaceMode.text,
            compact: compact,
            tabletDensity: tabletDensity,
            onTap: () => onChanged(TranslateWorkspaceMode.text),
          ),
          _ModePill(
            label: 'Sketchpad',
            active: mode == TranslateWorkspaceMode.sketchpad,
            compact: compact,
            tabletDensity: tabletDensity,
            onTap: () => onChanged(TranslateWorkspaceMode.sketchpad),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.compact,
    required this.tabletDensity,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool compact;
  final bool tabletDensity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: BoxConstraints(
          minHeight: compact ? 34 : (tabletDensity ? 42 : 40),
          minWidth: compact ? 94 : (tabletDensity ? 118 : 110),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: tabletDensity ? 15 : 13,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: tabletDensity ? 12.5 : (compact ? 11 : 11.5),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? cs.onPrimary : cs.onSurface.withAlpha(170),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
