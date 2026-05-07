import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';

class TranslateModeSwitch extends StatelessWidget {
  const TranslateModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
    this.compact = false,
    this.tabletDensity = false,
    this.desktopDensity = false,
  });

  final TranslateWorkspaceMode mode;
  final ValueChanged<TranslateWorkspaceMode> onChanged;
  final bool compact;
  final bool tabletDensity;
  final bool desktopDensity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double containerPadding = desktopDensity
        ? 5
        : tabletDensity
        ? 3
        : 3;
    return Container(
      padding: EdgeInsets.all(containerPadding),
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
            desktopDensity: desktopDensity,
            onTap: () => onChanged(TranslateWorkspaceMode.text),
          ),
          _ModePill(
            label: 'Sketchpad',
            active: mode == TranslateWorkspaceMode.sketchpad,
            compact: compact,
            tabletDensity: tabletDensity,
            desktopDensity: desktopDensity,
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
    required this.desktopDensity,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool compact;
  final bool tabletDensity;
  final bool desktopDensity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: BoxConstraints(
          minHeight: compact
              ? (desktopDensity ? 36 : 34)
              : (desktopDensity
                    ? 44
                    : tabletDensity
                    ? 40
                    : 40),
          minWidth: compact
              ? 94
              : (desktopDensity
                    ? 132
                    : tabletDensity
                    ? 108
                    : 110),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: desktopDensity
              ? 16
              : tabletDensity
              ? 12
              : 13,
          vertical: compact
              ? (desktopDensity || tabletDensity ? 8 : 7)
              : (desktopDensity ? 9 : 7),
        ),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: desktopDensity
                ? 12.8
                : tabletDensity
                ? 12
                : (compact ? 11 : 11.5),
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
